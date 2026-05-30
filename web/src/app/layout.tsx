import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "HAIKU TOUCH — Web Preview",
  description: "Figma/v0 UI web prototype for retro-music-app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body className="min-h-full antialiased">{children}</body>
    </html>
  );
}
