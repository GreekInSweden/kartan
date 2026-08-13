"use client";

import { useEffect, useState, useCallback } from "react";
import { KartanSvgMap } from "@/components/games/kartan/KartanSvgMap";
import type { KartanKategori, KartanSpeltyp } from "@/types/kartan";
import styles from "./admin.module.css";

interface RundaListItem {
  id: string;
  kategori_id: string;
  titel: string;
  typ: KartanSpeltyp;
  is_aktiv: boolean;
  visad_varde: string;
  ratt_plats_id: string | null;
  ratt_lat: number | null;
  ratt_lon: number | null;
}

interface PaketItem {
  id: string;
  namn: string;
  status: "utkast" | "publicerad";
  skapad_at: string;
}

interface PaketRundaLank {
  paket_id: string;
  runda_id: string;
  ordning: number;
}

export default function AdminKartanPage() {
  const [password, setPassword] = useState("");
  const [unlocked, setUnlocked] = useState(false);
  const [testandeId, setTestandeId] = useState<string | null>(null);
  const [oppetPaketId, setOppetPaketId] = useState<string | null>(null);

  const [kategorier, setKategorier] = useState<KartanKategori[]>([]);
  const [rundor, setRundor] = useState<RundaListItem[]>([]);
  const [paket, setPaket] = useState<PaketItem[]>([]);
  const [paketRundor, setPaketRundor] = useState<PaketRundaLank[]>([]);

  const loadData = useCallback(async () => {
    const res = await fetch(`/api/admin/kartan/list?adminPassword=${encodeURIComponent(password)}`);
    const data = await res.json();
    if (!res.ok) return;
    setKategorier(data.kategorier ?? []);
    setRundor(data.rundor ?? []);
    setPaket(data.paket ?? []);
    setPaketRundor(data.paketRundor ?? []);
  }, [password]);

  useEffect(() => {
    if (unlocked) loadData();
  }, [unlocked, loadData]);

  const rundorById = Object.fromEntries(rundor.map((r) => [r.id, r]));
  const rundorByKategori: Record<string, RundaListItem[]> = {};
  for (const r of rundor) {
    if (!rundorByKategori[r.kategori_id]) rundorByKategori[r.kategori_id] = [];
    rundorByKategori[r.kategori_id].push(r);
  }

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
        <a href="/spel/kartan" style={{ color: "#8b94a3", fontSize: 12, display: "inline-block", marginBottom: 20 }}>
          ← Till spelet
        </a>

        <PaketSektion
          adminPassword={password}
          paket={paket}
          paketRundor={paketRundor}
          rundorById={rundorById}
          oppetPaketId={oppetPaketId}
          setOppetPaketId={setOppetPaketId}
          testandeId={testandeId}
          setTestandeId={setTestandeId}
          onChanged={loadData}
        />

        <NyKategoriForm adminPassword={password} onCreated={loadData} />

        <NyRundaForm adminPassword={password} kategorier={kategorier} onCreated={loadData} />

        <div className={styles.section}>
          <p className={styles.sectionTitle}>Befintliga kategorier & rundor</p>
          {kategorier.length === 0 && <p className={styles.listItemMeta}>Inga kategorier ännu.</p>}
          {kategorier.map((k) => (
            <div key={k.id} style={{ marginBottom: 16 }}>
              <p style={{ fontWeight: 600, marginBottom: 4 }}>
                {k.namn} <span className={styles.listItemMeta}>({k.typ})</span>
              </p>
              {(rundorByKategori[k.id] ?? []).map((r) => {
                const testarNu = testandeId === r.id;
                return (
                  <div key={r.id} className={styles.listItem}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 10 }}>
                      <span>
                        {r.titel}{" "}
                        <span className={styles.listItemMeta}>
                          — {r.visad_varde} {r.is_aktiv ? "· aktiv" : "· inaktiv"}
                        </span>
                      </span>
                      <button
                        onClick={() => setTestandeId(testarNu ? null : r.id)}
                        className={styles.typeButton}
                        style={{ flexShrink: 0, color: testarNu ? "#e8b84b" : "#8b94a3" }}
                      >
                        {testarNu ? "Stäng" : "Testa"}
                      </button>
                    </div>
                    {testarNu && <TestaKarta runda={r} />}
                  </div>
                );
              })}
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

function TestaKarta({ runda }: { runda: RundaListItem }) {
  return (
    <div style={{ maxWidth: 280, margin: "10px 0" }}>
      <KartanSvgMap
        geoSource={runda.typ === "kommun" ? "sweden-municipalities" : "sweden-regions"}
        clickMode={runda.typ === "punkt" ? "point" : "region"}
        revealed={true}
        correctRegionId={runda.typ !== "punkt" ? runda.ratt_plats_id : null}
        correctPoint={
          runda.typ === "punkt" && runda.ratt_lat != null && runda.ratt_lon != null
            ? { lat: runda.ratt_lat, lon: runda.ratt_lon }
            : null
        }
      />
    </div>
  );
}

// ---------------------------------------------------------------------------

function PaketSektion({
  adminPassword,
  paket,
  paketRundor,
  rundorById,
  oppetPaketId,
  setOppetPaketId,
  testandeId,
  setTestandeId,
  onChanged,
}: {
  adminPassword: string;
  paket: PaketItem[];
  paketRundor: PaketRundaLank[];
  rundorById: Record<string, RundaListItem>;
  oppetPaketId: string | null;
  setOppetPaketId: (id: string | null) => void;
  testandeId: string | null;
  setTestandeId: (id: string | null) => void;
  onChanged: () => void;
}) {
  const [skapar, setSkapar] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function skapaPaket() {
    setSkapar(true);
    setError(null);
    try {
      const res = await fetch("/api/admin/kartan/paket", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ adminPassword }),
      });
      const data = await res.json();
      if (!res.ok) {
        setError(data.error ?? "Något gick fel.");
        return;
      }
      onChanged();
    } finally {
      setSkapar(false);
    }
  }

  async function togglaStatus(p: PaketItem) {
    const nyStatus = p.status === "publicerad" ? "utkast" : "publicerad";
    await fetch(`/api/admin/kartan/paket/${p.id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ adminPassword, status: nyStatus }),
    });
    onChanged();
  }

  return (
    <div className={styles.section}>
      <p className={styles.sectionTitle}>Paket</p>
      <p className={styles.pickerHint}>
        Ett paket har 10 frågor (5 kommun + 5 nålgissning), slumpade ur oanvända rundor. Publicera ett
        paket för att göra det synligt på spelarsidan.
      </p>

      <button className={styles.button} disabled={skapar} onClick={skapaPaket}>
        {skapar ? "Skapar…" : "Skapa nytt paket"}
      </button>
      {error && <p className={styles.errorNote}>{error}</p>}

      <div style={{ marginTop: 16 }}>
        {paket.length === 0 && <p className={styles.listItemMeta}>Inga paket ännu.</p>}
        {paket.map((p) => {
          const oppet = oppetPaketId === p.id;
          const rundorIPaket = paketRundor
            .filter((pr) => pr.paket_id === p.id)
            .sort((a, b) => a.ordning - b.ordning);

          return (
            <div key={p.id} style={{ marginBottom: 10, borderBottom: "1px solid #1c222c", paddingBottom: 10 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 10 }}>
                <span
                  onClick={() => setOppetPaketId(oppet ? null : p.id)}
                  style={{ cursor: "pointer", fontWeight: 600 }}
                >
                  {p.namn}{" "}
                  <span className={styles.listItemMeta}>
                    ({rundorIPaket.length} frågor · {new Date(p.skapad_at).toLocaleDateString("sv-SE")})
                  </span>
                </span>
                <button
                  onClick={() => togglaStatus(p)}
                  className={styles.typeButton}
                  style={{
                    flexShrink: 0,
                    borderColor: p.status === "publicerad" ? "#7fc8a0" : "#3a4250",
                    color: p.status === "publicerad" ? "#7fc8a0" : "#8b94a3",
                  }}
                >
                  {p.status === "publicerad" ? "● Publicerad" : "○ Utkast"}
                </button>
              </div>

              {oppet && (
                <div style={{ marginTop: 10, paddingLeft: 8 }}>
                  {rundorIPaket.map((pr, i) => {
                    const r = rundorById[pr.runda_id];
                    if (!r) return null;
                    const testarNu = testandeId === r.id;
                    return (
                      <div key={pr.runda_id} className={styles.listItem}>
                        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", gap: 10 }}>
                          <span>
                            {i + 1}. {r.titel}{" "}
                            <span className={styles.listItemMeta}>
                              ({r.typ}) — {r.visad_varde}
                            </span>
                          </span>
                          <button
                            onClick={() => setTestandeId(testarNu ? null : r.id)}
                            className={styles.typeButton}
                            style={{ flexShrink: 0, color: testarNu ? "#e8b84b" : "#8b94a3" }}
                          >
                            {testarNu ? "Stäng" : "Testa"}
                          </button>
                        </div>
                        {testarNu && <TestaKarta runda={r} />}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
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
  const [typ, setTyp] = useState<KartanSpeltyp>("kommun");
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
          className={`${styles.typeButton} ${typ === "kommun" ? styles.typeButtonActive : ""}`}
          onClick={() => setTyp("kommun")}
        >
          Kommunklick
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
    ((typ === "lan" && pickedPlatsId) ||
      (typ === "kommun" && pickedPlatsId) ||
      (typ === "punkt" && pickedPoint));

  return (
    <div className={styles.section}>
      <p className={styles.sectionTitle}>Ny runda (manuell)</p>

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
              : typ === "kommun"
              ? "Klicka på rätt kommun i kartan nedan."
              : "Klicka på rätt plats i kartan nedan."}
          </p>

          {pickedPlatsNamn && (
            <p className={styles.pickedValue}>
              Vald {typ === "kommun" ? "kommun" : "län"}: {pickedPlatsNamn}
            </p>
          )}
          {pickedPoint && (
            <p className={styles.pickedValue}>
              Vald punkt: {pickedPoint.lat.toFixed(4)}, {pickedPoint.lon.toFixed(4)}
            </p>
          )}

          <div style={{ maxWidth: 320, marginBottom: 16 }}>
            <KartanSvgMap
              geoSource={typ === "kommun" ? "sweden-municipalities" : "sweden-regions"}
              clickMode={typ === "punkt" ? "point" : "region"}
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
