import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Kan Du Alla — Kartan",
  description: "Kartan — gissa länet eller nålgissa platsen",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="sv" className="h-full antialiased">
      <body className="min-h-full flex flex-col">{children}</body>
    </html>
  );
}
