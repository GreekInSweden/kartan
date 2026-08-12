"use client";

import { useEffect, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { KartanSvgMap } from "@/components/games/kartan/KartanSvgMap";
import type { KartanKategori, KartanSpeltyp } from "@/types/kartan";
import styles from "./admin.module.css";

interface RundaListItem {
  id: string;
  titel: string;
  typ: KartanSpeltyp;
  is_aktiv: boolean;
  visad_varde: string;
}

export default function AdminKartanPage() {
  const [password, setPassword] = useState("");
  const [unlocked, setUnlocked] = useState(false);

  const [kategorier, setKategorier] = useState<KartanKategori[]>([]);
  const [rundorByKategori, setRundorByKategori] = useState<Record<string, RundaListItem[]>>({});

  const loadData = useCallback(async () => {
    const supabase = createClient();
    const { data: kats } = await supabase
      .from("kartan_kategorier")
      .select("id, namn, beskrivning, typ")
      .order("namn");
    setKategorier(
      (kats ?? []).map((k) => ({
        id: k.id,
        namn: k.namn,
        beskrivning: k.beskrivning,
        typ: k.typ,
      }))
    );

    const { data: rundor } = await supabase
      .from("kartan_rundor")
      .select("id, kategori_id, titel, typ, is_aktiv, visad_varde")
      .order("skapad_at", { ascending: false });

    const grouped: Record<string, RundaListItem[]> = {};
    for (const r of rundor ?? []) {
      if (!grouped[r.kategori_id]) grouped[r.kategori_id] = [];
      grouped[r.kategori_id].push(r);
    }
    setRundorByKategori(grouped);
  }, []);

  useEffect(() => {
    if (unlocked) loadData();
  }, [unlocked, loadData]);

  if (!unlocked) {
    return (
      <div className={styles.page}>
        <div className={styles.container}>
          <p className={styles.eyebrow}>KAN DU ALLA — ADMIN</p>
          <h1 className={styles.title}>Kartan</h1>
          <div className={styles.gateBox}>
            <label className={styles.label}>Admin-lösenord</label>
            <input
              type="password"
              className={styles.input}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && setUnlocked(true)}
            />
            <button className={styles.button} onClick={() => setUnlocked(true)}>
              Lås upp
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.page}>
      <div className={styles.container}>
        <p className={styles.eyebrow}>KAN DU ALLA — ADMIN</p>
        <h1 className={styles.title}>Kartan</h1>

        <NyKategoriForm
          adminPassword={password}
          onCreated={loadData}
        />

        <NyRundaForm
          adminPassword={password}
          kategorier={kategorier}
          onCreated={loadData}
        />

        <div className={styles.section}>
          <p className={styles.sectionTitle}>Befintliga kategorier & rundor</p>
          {kategorier.length === 0 && (
            <p className={styles.listItemMeta}>Inga kategorier ännu.</p>
          )}
          {kategorier.map((k) => (
            <div key={k.id} style={{ marginBottom: 16 }}>
              <p style={{ fontWeight: 600, marginBottom: 4 }}>
                {k.namn} <span className={styles.listItemMeta}>({k.typ})</span>
              </p>
              {(rundorByKategori[k.id] ?? []).map((r) => (
                <div key={r.id} className={styles.listItem}>
                  {r.titel}{" "}
                  <span className={styles.listItemMeta}>
                    — {r.visad_varde} {r.is_aktiv ? "· aktiv" : "· inaktiv"}
                  </span>
                </div>
              ))}
              {(rundorByKategori[k.id] ?? []).length === 0 && (
                <p className={styles.listItemMeta}>Inga rundor i denna kategori ännu.</p>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------

function NyKategoriForm({
  adminPassword,
  onCreated,
}: {
  adminPassword: string;
  onCreated: () => void;
}) {
  const [namn, setNamn] = useState("");
  const [beskrivning, setBeskrivning] = useState("");
  const [typ, setTyp] = useState<KartanSpeltyp>("lan");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  async function handleSubmit() {
    setSubmitting(true);
    setError(null);
    setSuccess(false);
    try {
      const res = await fetch("/api/admin/kartan/kategorier", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ adminPassword, namn, beskrivning, typ }),
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error ?? "Något gick fel.");
        return;
      }
      setSuccess(true);
      setNamn("");
      setBeskrivning("");
      onCreated();
    } catch {
      setError("Kunde inte nå servern.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className={styles.section}>
      <p className={styles.sectionTitle}>Ny kategori</p>

      <div className={styles.selectTypeRow}>
        <button
          className={`${styles.typeButton} ${typ === "lan" ? styles.typeButtonActive : ""}`}
          onClick={() => setTyp("lan")}
        >
          Länsklick
        </button>
        <button
          className={`${styles.typeButton} ${typ === "punkt" ? styles.typeButtonActive : ""}`}
          onClick={() => setTyp("punkt")}
        >
          Nålgissning
        </button>
      </div>

      <label className={styles.label}>Namn</label>
      <input
        className={styles.input}
        value={namn}
        onChange={(e) => setNamn(e.target.value)}
        placeholder="T.ex. Historiska händelser"
      />

      <label className={styles.label}>Beskrivning (valfritt)</label>
      <input
        className={styles.input}
        value={beskrivning}
        onChange={(e) => setBeskrivning(e.target.value)}
      />

      <button className={styles.button} disabled={!namn || submitting} onClick={handleSubmit}>
        Skapa kategori
      </button>

      {error && <p className={styles.errorNote}>{error}</p>}
      {success && <p className={styles.successNote}>Kategori skapad!</p>}
    </div>
  );
}

// ---------------------------------------------------------------------------

function NyRundaForm({
  adminPassword,
  kategorier,
  onCreated,
}: {
  adminPassword: string;
  kategorier: KartanKategori[];
  onCreated: () => void;
}) {
  const [kategoriId, setKategoriId] = useState("");
  const [titel, setTitel] = useState("");
  const [visadVarde, setVisadVarde] = useState("");
  const [toleransKm, setToleransKm] = useState(15);
  const [pickedPlatsId, setPickedPlatsId] = useState<string | null>(null);
  const [pickedPlatsNamn, setPickedPlatsNamn] = useState<string | null>(null);
  const [pickedPoint, setPickedPoint] = useState<{ lat: number; lon: number } | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const valdKategori = kategorier.find((k) => k.id === kategoriId);
  const typ = valdKategori?.typ;

  async function handleSubmit() {
    setSubmitting(true);
    setError(null);
    setSuccess(false);
    try {
      const res = await fetch("/api/admin/kartan/rundor", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          adminPassword,
          kategoriId,
          titel,
          typ,
          rattPlatsId: pickedPlatsId,
          rattLat: pickedPoint?.lat,
          rattLon: pickedPoint?.lon,
          toleransKm,
          visadVarde,
        }),
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error ?? "Något gick fel.");
        return;
      }
      setSuccess(true);
      setTitel("");
      setVisadVarde("");
      setPickedPlatsId(null);
      setPickedPlatsNamn(null);
      setPickedPoint(null);
      onCreated();
    } catch {
      setError("Kunde inte nå servern.");
    } finally {
      setSubmitting(false);
    }
  }

  const canSubmit =
    kategoriId &&
    titel &&
    visadVarde &&
    ((typ === "lan" && pickedPlatsId) || (typ === "punkt" && pickedPoint));

  return (
    <div className={styles.section}>
      <p className={styles.sectionTitle}>Ny runda</p>

      <label className={styles.label}>Kategori</label>
      <select
        className={styles.input}
        value={kategoriId}
        onChange={(e) => {
          setKategoriId(e.target.value);
          setPickedPlatsId(null);
          setPickedPlatsNamn(null);
          setPickedPoint(null);
        }}
      >
        <option value="">Välj kategori…</option>
        {kategorier.map((k) => (
          <option key={k.id} value={k.id}>
            {k.namn} ({k.typ})
          </option>
        ))}
      </select>

      {kategoriId && (
        <>
          <label className={styles.label}>Fråga</label>
          <input
            className={styles.input}
            value={titel}
            onChange={(e) => setTitel(e.target.value)}
            placeholder="T.ex. I vilket län ligger Sveriges huvudstad?"
          />

          <label className={styles.label}>Facit-text (visas vid avslöjande)</label>
          <input
            className={styles.input}
            value={visadVarde}
            onChange={(e) => setVisadVarde(e.target.value)}
            placeholder="T.ex. Stockholm ligger i Stockholms län"
          />

          {typ === "punkt" && (
            <>
              <label className={styles.label}>Tolerans (km för fullträff)</label>
              <input
                type="number"
                className={styles.input}
                value={toleransKm}
                onChange={(e) => setToleransKm(Number(e.target.value))}
              />
            </>
          )}

          <p className={styles.pickerHint}>
            {typ === "lan"
              ? "Klicka på rätt län i kartan nedan."
              : "Klicka på rätt plats i kartan nedan."}
          </p>

          {pickedPlatsNamn && (
            <p className={styles.pickedValue}>Valt län: {pickedPlatsNamn}</p>
          )}
          {pickedPoint && (
            <p className={styles.pickedValue}>
              Vald punkt: {pickedPoint.lat.toFixed(4)}, {pickedPoint.lon.toFixed(4)}
            </p>
          )}

          <div style={{ maxWidth: 320, marginBottom: 16 }}>
            <KartanSvgMap
              geoSource="sweden-regions"
              clickMode={typ === "lan" ? "region" : "point"}
              guessRegionId={pickedPlatsId}
              guessPoint={pickedPoint}
              revealed={false}
              onRegionClick={(id, namn) => {
                setPickedPlatsId(id);
                setPickedPlatsNamn(namn);
              }}
              onMapClick={(lat, lon) => setPickedPoint({ lat, lon })}
            />
          </div>

          <button className={styles.button} disabled={!canSubmit || submitting} onClick={handleSubmit}>
            Skapa runda
          </button>

          {error && <p className={styles.errorNote}>{error}</p>}
          {success && <p className={styles.successNote}>Runda skapad och aktiverad!</p>}
        </>
      )}
    </div>
  );
}
