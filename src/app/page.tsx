import Link from "next/link";

export default function Home() {
  return (
    <main style={{ maxWidth: 460, margin: "60px auto", padding: "0 16px", fontFamily: "system-ui" }}>
      <h1>Kan Du Alla — projekt</h1>
      <p>
        <Link href="/spel/kartan">→ Öppna Kartan</Link>
      </p>
    </main>
  );
}
