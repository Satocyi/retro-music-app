import { useState, useEffect } from "react";

interface HaikuData {
  year: number;
  season: string;
  place: string;
  kigo: string;
  reader: string;
}

const HAIKU_SAMPLES: HaikuData[] = [
  { year: 1994, season: "春", place: "曇れ", kigo: "家", reader: "ひとり" },
  { year: 1867, season: "冬", place: "雪原", kigo: "霜", reader: "旅人" },
  { year: 1923, season: "秋", place: "山里", kigo: "月", reader: "老翁" },
  { year: 1945, season: "夏", place: "海辺", kigo: "波", reader: "少年" },
  { year: 2003, season: "春", place: "桜道", kigo: "花", reader: "恋人" },
];

interface Props {
  haiku: HaikuData;
  isGenerating: boolean;
}

export function DotMatrixScreen({ haiku, isGenerating }: Props) {
  const [blink, setBlink] = useState(true);

  useEffect(() => {
    const id = setInterval(() => setBlink((b) => !b), 600);
    return () => clearInterval(id);
  }, []);

  const rows = [
    { label: "年", value: haiku.season },
    { label: "場所", value: haiku.place },
    { label: "季語", value: haiku.kigo },
    { label: "読者", value: haiku.reader },
  ];

  return (
    <div
      className="relative w-full rounded-md overflow-hidden select-none"
      style={{
        background: "linear-gradient(180deg, #0a1a0a 0%, #0d1f0d 100%)",
        border: "2px solid #1a1a1a",
        boxShadow: "inset 0 2px 8px rgba(0,0,0,0.8), inset 0 0 20px rgba(0,80,0,0.15)",
        fontFamily: "'Courier New', monospace",
        padding: "10px 12px",
        minHeight: "130px",
      }}
    >
      {/* Scanline overlay */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          backgroundImage:
            "repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.18) 2px, rgba(0,0,0,0.18) 4px)",
          zIndex: 1,
        }}
      />

      {/* Screen glare */}
      <div
        className="absolute top-0 left-0 right-0 pointer-events-none"
        style={{
          height: "35%",
          background:
            "linear-gradient(180deg, rgba(120,255,120,0.04) 0%, transparent 100%)",
          zIndex: 2,
        }}
      />

      <div className="relative" style={{ zIndex: 3 }}>
        {/* Header row */}
        <div className="flex justify-between items-center mb-2" style={{ borderBottom: "1px solid #1a4a1a" }}>
          <span
            style={{
              color: "#4aff4a",
              fontSize: "9px",
              letterSpacing: "0.15em",
              textShadow: "0 0 6px #00ff00",
              opacity: 0.85,
            }}
          >
            HAIKU TOUCH
          </span>
          <span
            style={{
              color: "#3acc3a",
              fontSize: "9px",
              letterSpacing: "0.05em",
              textShadow: "0 0 4px #00cc00",
            }}
          >
            ●{blink ? "STANDBY" : "STANDBY"}
          </span>
        </div>

        {/* Year */}
        <div className="flex justify-between items-baseline mb-1">
          <span style={{ color: "#2a8a2a", fontSize: "9px" }}></span>
          <span
            style={{
              color: isGenerating ? "#1a5a1a" : "#7fff7f",
              fontSize: "22px",
              letterSpacing: "0.1em",
              textShadow: isGenerating ? "none" : "0 0 10px #00ff00, 0 0 20px #00aa00",
              transition: "all 0.3s",
            }}
          >
            {haiku.year}
          </span>
          <div
            style={{
              width: "18px",
              height: "10px",
              border: "1px solid #3aaa3a",
              borderRadius: "1px",
              padding: "1px",
            }}
          >
            <div
              style={{
                height: "100%",
                width: "70%",
                background: "#3aff3a",
                boxShadow: "0 0 4px #00ff00",
              }}
            />
          </div>
        </div>

        {/* Data rows */}
        {rows.map(({ label, value }) => (
          <div key={label} className="flex items-center gap-1 mb-0.5">
            <span
              style={{
                color: "#2a7a2a",
                fontSize: "9px",
                minWidth: "22px",
                letterSpacing: "0.05em",
              }}
            >
              {label}
            </span>
            <span style={{ color: "#1a4a1a", fontSize: "8px" }}>:</span>
            <span
              style={{
                color: isGenerating ? "#1a5a1a" : "#5adf5a",
                fontSize: "11px",
                letterSpacing: "0.08em",
                textShadow: isGenerating ? "none" : "0 0 6px #00cc00",
                transition: "all 0.3s",
              }}
            >
              {isGenerating ? "----" : value}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

export { HAIKU_SAMPLES };
export type { HaikuData };
