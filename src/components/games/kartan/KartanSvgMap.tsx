"use client";

import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import type { FeatureCollection } from "geojson";
import { buildSwedenProjection } from "@/lib/kartan/geo";
import styles from "./kartan.module.css";

const VIEWPORT_W = 400;
const VIEWPORT_H = 760;
const MIN_SCALE = 1;
const MAX_SCALE = 8;

export interface RevealTarget {
  x: number;
  y: number;
}

interface KartanSvgMapProps {
  /** "sweden-regions" (21 län) eller "sweden-municipalities" (290 kommuner) */
  geoSource: "sweden-regions" | "sweden-municipalities";
  /** Om satt: klick på en region returnerar dess id. Annars är kartan fri att klicka var som helst (nålgissning). */
  clickMode: "region" | "point";
  guessRegionId?: string | null;
  guessPoint?: { lat: number; lon: number } | null;
  correctRegionId?: string | null;
  correctPoint?: { lat: number; lon: number } | null;
  revealed: boolean;
  onRegionClick?: (id: string, name: string) => void;
  onMapClick?: (lat: number, lon: number, pixel: { x: number; y: number }) => void;
}

interface PanZoom {
  x: number;
  y: number;
  scale: number;
}

const IDENTITY: PanZoom = { x: 0, y: 0, scale: 1 };

export function KartanSvgMap({
  geoSource,
  clickMode,
  guessRegionId,
  guessPoint,
  correctRegionId,
  correctPoint,
  revealed,
  onRegionClick,
  onMapClick,
}: KartanSvgMapProps) {
  const [geoData, setGeoData] = useState<FeatureCollection | null>(null);
  const svgRef = useRef<SVGSVGElement>(null);

  // --- Manuell pan/zoom (scroll, drag, tvåfingers-pinch) ---
  const [panZoom, setPanZoom] = useState<PanZoom>(IDENTITY);
  const dragState = useRef<{ startX: number; startY: number; origX: number; origY: number } | null>(null);
  const pinchState = useRef<{ startDist: number; origScale: number; midSvgX: number; midSvgY: number } | null>(
    null
  );
  const draggedRef = useRef(false);
  const [hoveredName, setHoveredName] = useState<string | null>(null);

  // Nollställ pan/zoom när en ny fråga börjar (revealed går från true -> false,
  // eller komponenten just monterats för första gången).
  const prevRevealed = useRef(revealed);
  useEffect(() => {
    if (prevRevealed.current && !revealed) {
      setPanZoom(IDENTITY);
    }
    prevRevealed.current = revealed;
  }, [revealed]);

  useEffect(() => {
    let cancelled = false;
    fetch(`/data/kartan/${geoSource}.geojson`)
      .then((res) => res.json())
      .then((data: FeatureCollection) => {
        if (!cancelled) setGeoData(data);
      });
    return () => {
      cancelled = true;
    };
  }, [geoSource]);

  const { projection, path } = useMemo(() => {
    if (!geoData) return { projection: null, path: null };
    return buildSwedenProjection(geoData, VIEWPORT_W, VIEWPORT_H);
  }, [geoData]);

  const clientToSvg = useCallback((clientX: number, clientY: number) => {
    const rect = svgRef.current!.getBoundingClientRect();
    return {
      x: ((clientX - rect.left) / rect.width) * VIEWPORT_W,
      y: ((clientY - rect.top) / rect.height) * VIEWPORT_H,
    };
  }, []);

  const handleWheel = useCallback(
    (e: React.WheelEvent<SVGSVGElement>) => {
      if (revealed) return;
      e.preventDefault();
      const { x: svgX, y: svgY } = clientToSvg(e.clientX, e.clientY);
      setPanZoom((pz) => {
        const factor = e.deltaY < 0 ? 1.25 : 0.8;
        const newScale = Math.min(MAX_SCALE, Math.max(MIN_SCALE, pz.scale * factor));
        const dataX = (svgX - pz.x) / pz.scale;
        const dataY = (svgY - pz.y) / pz.scale;
        return { scale: newScale, x: svgX - dataX * newScale, y: svgY - dataY * newScale };
      });
    },
    [revealed, clientToSvg]
  );

  const handlePointerDown = useCallback(
    (e: React.PointerEvent<SVGSVGElement>) => {
      if (revealed) return;
      draggedRef.current = false;
      dragState.current = { startX: e.clientX, startY: e.clientY, origX: panZoom.x, origY: panZoom.y };
      (e.target as Element).setPointerCapture?.(e.pointerId);
    },
    [revealed, panZoom.x, panZoom.y]
  );

  const handlePointerMove = useCallback(
    (e: React.PointerEvent<SVGSVGElement>) => {
      if (!dragState.current || !svgRef.current) return;
      const rect = svgRef.current.getBoundingClientRect();
      const dx = ((e.clientX - dragState.current.startX) / rect.width) * VIEWPORT_W;
      const dy = ((e.clientY - dragState.current.startY) / rect.height) * VIEWPORT_H;
      if (Math.abs(dx) > 2 || Math.abs(dy) > 2) draggedRef.current = true;
      setPanZoom((pz) => ({ ...pz, x: dragState.current!.origX + dx, y: dragState.current!.origY + dy }));
    },
    []
  );

  const handlePointerUp = useCallback(() => {
    dragState.current = null;
  }, []);

  // --- Tvåfingers-pinch (touch) ---
  const handleTouchStart = useCallback(
    (e: React.TouchEvent<SVGSVGElement>) => {
      if (revealed || e.touches.length !== 2) return;
      const [t1, t2] = [e.touches[0], e.touches[1]];
      const dist = Math.hypot(t2.clientX - t1.clientX, t2.clientY - t1.clientY);
      const mid = clientToSvg((t1.clientX + t2.clientX) / 2, (t1.clientY + t2.clientY) / 2);
      pinchState.current = { startDist: dist, origScale: panZoom.scale, midSvgX: mid.x, midSvgY: mid.y };
    },
    [revealed, panZoom.scale, clientToSvg]
  );

  const handleTouchMove = useCallback(
    (e: React.TouchEvent<SVGSVGElement>) => {
      if (!pinchState.current || e.touches.length !== 2) return;
      e.preventDefault();
      const [t1, t2] = [e.touches[0], e.touches[1]];
      const dist = Math.hypot(t2.clientX - t1.clientX, t2.clientY - t1.clientY);
      const ratio = dist / pinchState.current.startDist;
      setPanZoom((pz) => {
        const newScale = Math.min(MAX_SCALE, Math.max(MIN_SCALE, pinchState.current!.origScale * ratio));
        const { midSvgX, midSvgY } = pinchState.current!;
        const dataX = (midSvgX - pz.x) / pz.scale;
        const dataY = (midSvgY - pz.y) / pz.scale;
        return { scale: newScale, x: midSvgX - dataX * newScale, y: midSvgY - dataY * newScale };
      });
    },
    []
  );

  const handleTouchEnd = useCallback((e: React.TouchEvent<SVGSVGElement>) => {
    if (e.touches.length < 2) pinchState.current = null;
  }, []);

  if (!geoData || !projection || !path) {
    return (
      <div className={styles.mapLoading} style={{ aspectRatio: `${VIEWPORT_W}/${VIEWPORT_H}` }}>
        Laddar karta…
      </div>
    );
  }

  const proj = projection;

  const correctPixel =
    clickMode === "point" && correctPoint
      ? proj([correctPoint.lon, correctPoint.lat])
      : clickMode === "region" && correctRegionId
      ? centroidOfFeature(geoData, correctRegionId, proj)
      : null;

  const guessPixel =
    clickMode === "point" && guessPoint ? proj([guessPoint.lon, guessPoint.lat]) : null;

  const revealStyle =
    revealed && correctPixel
      ? {
          transformOrigin: `${correctPixel[0]}px ${correctPixel[1]}px`,
          transform: "scale(2.2)",
        }
      : { transform: "scale(1)" };

  function handleSvgClick(e: React.MouseEvent<SVGSVGElement>) {
    if (draggedRef.current) return; // en drag ska inte räknas som klick
    if (clickMode !== "point" || revealed || !onMapClick || !svgRef.current) return;
    const rect = svgRef.current.getBoundingClientRect();
    const svgX = ((e.clientX - rect.left) / rect.width) * VIEWPORT_W;
    const svgY = ((e.clientY - rect.top) / rect.height) * VIEWPORT_H;
    const px = (svgX - panZoom.x) / panZoom.scale;
    const py = (svgY - panZoom.y) / panZoom.scale;
    const inverted = proj.invert?.([px, py]);
    if (!inverted) return;
    const [lon, lat] = inverted;
    onMapClick(lat, lon, { x: px, y: py });
  }

  return (
    <div className={styles.mapWrap} style={{ position: "relative" }}>
      {hoveredName && !revealed && (
        <div className={styles.hoverBadge}>{hoveredName}</div>
      )}
      <svg
        ref={svgRef}
        viewBox={`0 0 ${VIEWPORT_W} ${VIEWPORT_H}`}
        className={styles.mapSvg}
        onClick={handleSvgClick}
        onWheel={handleWheel}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerLeave={handlePointerUp}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        style={{
          cursor: revealed ? "default" : dragState.current ? "grabbing" : clickMode === "point" ? "crosshair" : "grab",
          touchAction: "none",
        }}
      >
        <g style={{ transform: `translate(${panZoom.x}px, ${panZoom.y}px) scale(${panZoom.scale})` }}>
          <g className={styles.zoomGroup} style={revealStyle}>
            {geoData.features.map((feature) => {
              const id = String((feature.properties as { id: string }).id);
              const name = (feature.properties as { name: string }).name;
              const isGuess = clickMode === "region" && guessRegionId === id;
              const isCorrect = clickMode === "region" && revealed && correctRegionId === id;
              const d = path(feature) ?? undefined;

              let className = styles.region;
              if (isCorrect) className += ` ${styles.regionCorrect}`;
              else if (isGuess) className += ` ${styles.regionGuess}`;
              else if (revealed) className += ` ${styles.regionDimmed}`;

              return (
                <path
                  key={id}
                  d={d}
                  className={className}
                  onMouseEnter={() => !revealed && clickMode === "region" && setHoveredName(name)}
                  onMouseLeave={() => setHoveredName(null)}
                  onClick={() => {
                    if (draggedRef.current) return;
                    if (clickMode === "region" && !revealed && onRegionClick) {
                      onRegionClick(id, name);
                    }
                  }}
                />
              );
            })}

            {clickMode === "point" && guessPixel && (
              <circle cx={guessPixel[0]} cy={guessPixel[1]} r={5} className={styles.guessDot} />
            )}

            {clickMode === "point" && revealed && correctPixel && (
              <>
                {guessPixel && (
                  <line
                    x1={guessPixel[0]}
                    y1={guessPixel[1]}
                    x2={correctPixel[0]}
                    y2={correctPixel[1]}
                    className={styles.distanceLine}
                  />
                )}
                <circle cx={correctPixel[0]} cy={correctPixel[1]} r={4} className={styles.correctDot} />
                <circle cx={correctPixel[0]} cy={correctPixel[1]} r={4} className={styles.pingRing} />
              </>
            )}
          </g>
        </g>
      </svg>
      {!revealed && (
        <div className={styles.zoomHint}>Scrolla / nyp för att zooma, dra för att panorera</div>
      )}
    </div>
  );
}

function centroidOfFeature(
  geoData: FeatureCollection,
  id: string,
  projection: ReturnType<typeof buildSwedenProjection>["projection"]
): [number, number] | null {
  const feature = geoData.features.find(
    (f) => String((f.properties as { id: string }).id) === id
  );
  if (!feature || feature.geometry.type === "GeometryCollection") return null;
  const coords: number[][] = [];
  const collect = (geom: typeof feature.geometry) => {
    if (geom.type === "Polygon") geom.coordinates.forEach((ring) => coords.push(...ring));
    if (geom.type === "MultiPolygon")
      geom.coordinates.forEach((poly) => poly.forEach((ring) => coords.push(...ring)));
  };
  collect(feature.geometry);
  const projected = coords.map((c) => projection(c as [number, number])).filter(Boolean) as [
    number,
    number
  ][];
  if (projected.length === 0) return null;
  const xs = projected.map((p) => p[0]);
  const ys = projected.map((p) => p[1]);
  return [(Math.min(...xs) + Math.max(...xs)) / 2, (Math.min(...ys) + Math.max(...ys)) / 2];
}
