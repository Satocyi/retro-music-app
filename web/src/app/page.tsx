"use client";

import { useState } from "react";
import { DotMatrixScreen, HAIKU_SAMPLES } from "./components/DotMatrixScreen";
import { Clickwheel } from "./components/Clickwheel";

export default function HomePage() {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isGenerating, setIsGenerating] = useState(false);

  const haiku = HAIKU_SAMPLES[currentIndex];

  const advance = () => {
    setCurrentIndex((i) => (i + 1) % HAIKU_SAMPLES.length);
  };

  const retreat = () => {
    setCurrentIndex(
      (i) => (i - 1 + HAIKU_SAMPLES.length) % HAIKU_SAMPLES.length
    );
  };

  const generate = () => {
    setIsGenerating(true);
    setTimeout(() => {
      setCurrentIndex((i) => (i + 1) % HAIKU_SAMPLES.length);
      setIsGenerating(false);
    }, 750);
  };

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        minHeight: "100dvh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "#1a1a1a",
      }}
    >
      <div
        style={{
          width: "220px",
          borderRadius: "28px",
          padding: "16px 16px 20px",
          position: "relative",
          background:
            "linear-gradient(160deg, #d6d6d6 0%, #bebebe 18%, #b6b6b6 38%, #c6c6c6 58%, #cecece 78%, #c2c2c2 100%)",
          boxShadow:
            "0 20px 60px rgba(0,0,0,0.8), 0 6px 16px rgba(0,0,0,0.5), inset 0 1px 2px rgba(255,255,255,0.7), inset 0 -1px 2px rgba(0,0,0,0.28)",
          userSelect: "none",
        }}
      >
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: "28px",
            backgroundImage:
              "repeating-linear-gradient(90deg, transparent 0px, transparent 2px, rgba(255,255,255,0.038) 2px, rgba(255,255,255,0.038) 4px)",
            pointerEvents: "none",
          }}
        />

        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            right: 0,
            height: "42%",
            borderRadius: "28px 28px 0 0",
            background:
              "linear-gradient(170deg, rgba(255,255,255,0.18) 0%, transparent 55%)",
            pointerEvents: "none",
          }}
        />

        <div style={{ position: "relative", zIndex: 1 }}>
          <div
            style={{
              display: "flex",
              justifyContent: "flex-end",
              marginBottom: "10px",
            }}
          >
            <div
              style={{
                width: "6px",
                height: "6px",
                borderRadius: "50%",
                background: isGenerating ? "#e06820" : "#44aa44",
                boxShadow: isGenerating
                  ? "0 0 5px #e06820"
                  : "0 0 4px #44aa44",
                transition: "all 0.3s",
              }}
            />
          </div>

          <div
            style={{
              background: "linear-gradient(180deg, #181818 0%, #121212 100%)",
              borderRadius: "7px",
              padding: "3px",
              boxShadow:
                "inset 0 2px 5px rgba(0,0,0,0.85), 0 1px 3px rgba(255,255,255,0.14)",
              marginBottom: "18px",
            }}
          >
            <DotMatrixScreen haiku={haiku} isGenerating={isGenerating} />
          </div>

          <div
            style={{
              display: "flex",
              justifyContent: "center",
              marginBottom: "16px",
            }}
          >
            <div
              style={{
                background:
                  "radial-gradient(circle at 48% 44%, #c0c0c0 0%, #ababab 40%, #9e9e9e 70%, #b0b0b0 100%)",
                borderRadius: "50%",
                padding: "9px",
                boxShadow:
                  "0 4px 14px rgba(0,0,0,0.42), inset 0 1px 3px rgba(255,255,255,0.5), inset 0 -1px 3px rgba(0,0,0,0.22)",
              }}
            >
              <Clickwheel
                size={154}
                onAdvance={advance}
                onRetreat={retreat}
                onOK={generate}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
