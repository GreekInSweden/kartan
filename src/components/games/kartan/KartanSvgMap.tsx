"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import type { FeatureCollection } from "geojson";
import { buildSwedenProjection } from "@/lib/kartan/geo";
import styles from "./kartan.module.css";

const VIEWPORT_W = 400;
const VIEWPORT_H = 760;

export interface RevealTarget {
  x: number; // pixel-koordinat i SVG-viewporten (redan projicerad)
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

  if (!geoData || !projection || !path) {
    return (
      <div className={styles.mapLoading} style={{ aspectRatio: `${VIEWPORT_W}/${VIEWPORT_H}` }}>
        Laddar karta…
      </div>
    );
  }

  // TypeScript kan inte smalna av `projection` inuti nästlade funktioner (closures),
  // trots early-return-guarden ovan — så vi binder en garanterat icke-null referens här.
  const proj = projection;

  // Projicera facit/gissning till pixelkoordinater för reveal-animationen
  const correctPixel =
    clickMode === "point" && correctPoint
      ? proj([correctPoint.lon, correctPoint.lat])
      : clickMode === "region" && correctRegionId
      ? centroidOfFeature(geoData, correctRegionId, proj)
      : null;

  const guessPixel =
    clickMode === "point" && guessPoint ? proj([guessPoint.lon, guessPoint.lat]) : null;

  const zoomStyle =
    revealed && correctPixel
      ? {
          transformOrigin: `${correctPixel[0]}px ${correctPixel[1]}px`,
          transform: "scale(2.2)",
        }
      : { transform: "scale(1)" };

  function handleSvgClick(e: React.MouseEvent<SVGSVGElement>) {
    if (clickMode !== "point" || revealed || !onMapClick || !svgRef.current) return;
    const rect = svgRef.current.getBoundingClientRect();
    const px = ((e.clientX - rect.left) / rect.width) * VIEWPORT_W;
    const py = ((e.clientY - rect.top) / rect.height) * VIEWPORT_H;
    const inverted = proj.invert?.([px, py]);
    if (!inverted) return;
    const [lon, lat] = inverted;
    onMapClick(lat, lon, { x: px, y: py });
  }

  return (
    <div className={styles.mapWrap}>
      <svg
        ref={svgRef}
        viewBox={`0 0 ${VIEWPORT_W} ${VIEWPORT_H}`}
        className={styles.mapSvg}
        onClick={handleSvgClick}
        style={{ cursor: clickMode === "point" && !revealed ? "crosshair" : "default" }}
      >
        <g className={styles.zoomGroup} style={zoomStyle}>
          {geoData.features.map((feature) => {
            const id = String((feature.properties as { id: string }).id);
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
                onClick={() => {
                  if (clickMode === "region" && !revealed && onRegionClick) {
                    onRegionClick(id, (feature.properties as { name: string }).name);
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
      </svg>
    </div>
  );
}

/** Hittar centroid-pixelkoordinat för en region baserat på dess projicerade path-bounds. */
function centroidOfFeature(
  geoData: FeatureCollection,
  id: string,
  projection: ReturnType<typeof buildSwedenProjection>["projection"]
): [number, number] | null {
  const feature = geoData.features.find(
    (f) => String((f.properties as { id: string }).id) === id
  );
  if (!feature || feature.geometry.type === "GeometryCollection") return null;
  // Enkelt bounding-box-centrum av projicerade koordinater — tillräckligt för glow/zoom-targeting.
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
