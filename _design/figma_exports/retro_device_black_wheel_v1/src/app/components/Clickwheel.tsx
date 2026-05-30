import { useState, useRef } from "react";

interface Props {
  onAdvance: () => void;
  onRetreat: () => void;
  onOK: () => void;
  size?: number;
}

const NOTCH_COUNT = 40;
const STEP_DEG = 360 / NOTCH_COUNT;

export function Clickwheel({ onAdvance, onRetreat, onOK, size = 154 }: Props) {
  const [rotation, setRotation] = useState(0);
  const [okPressed, setOkPressed] = useState(false);
  const wheelRef = useRef<HTMLDivElement>(null);

  const half = size / 2;
  const outerR = half - 2;
  const innerR = half * 0.46;
  const centerR = half * 0.30;

  // Notch rects: each at 12 o'clock then rotated around center
  const notchW = 1.5;
  const notchH = 6;
  const notchR = outerR - 4;

  const handleRingPointer = (e: React.PointerEvent) => {
    if (!wheelRef.current) return;
    const rect = wheelRef.current.getBoundingClientRect();
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    const dx = e.clientX - cx;
    const dy = e.clientY - cy;
    const dist = Math.sqrt(dx * dx + dy * dy);

    const rOuter = (size / 2) * 0.95;
    const rInner = (size / 2) * 0.34;

    if (dist < rInner || dist > rOuter) return;

    // Right half of ring → advance (clockwise), left half → retreat
    if (dx >= 0) {
      setRotation((r) => r + STEP_DEG);
      onAdvance();
    } else {
      setRotation((r) => r - STEP_DEG);
      onRetreat();
    }
  };

  const handleOK = (e: React.PointerEvent) => {
    e.stopPropagation();
    setOkPressed(true);
    onOK();
    setTimeout(() => setOkPressed(false), 160);
  };

  return (
    <div
      ref={wheelRef}
      onPointerDown={handleRingPointer}
      style={{
        width: size,
        height: size,
        position: "relative",
        flexShrink: 0,
        cursor: "pointer",
        userSelect: "none",
      }}
    >
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        style={{ position: "absolute", inset: 0 }}
      >
        <defs>
          {/* Outer disc gradient */}
          <radialGradient id="outerDisc" cx="42%" cy="38%" r="58%">
            <stop offset="0%" stopColor="#5a5a5a" />
            <stop offset="45%" stopColor="#3a3a3a" />
            <stop offset="100%" stopColor="#242424" />
          </radialGradient>
          {/* Notch ring gradient — slightly lighter band at outer edge */}
          <radialGradient id="notchRing" cx="50%" cy="50%" r="50%">
            <stop offset="72%" stopColor="transparent" />
            <stop offset="82%" stopColor="rgba(90,88,84,0.5)" />
            <stop offset="92%" stopColor="rgba(70,68,64,0.3)" />
            <stop offset="100%" stopColor="transparent" />
          </radialGradient>
          {/* Inner ring gradient */}
          <radialGradient id="innerRing" cx="44%" cy="40%" r="56%">
            <stop offset="0%" stopColor="#404040" />
            <stop offset="50%" stopColor="#2e2e2e" />
            <stop offset="100%" stopColor="#222222" />
          </radialGradient>
          {/* Center button gradient — normal */}
          <radialGradient id="centerNormal" cx="42%" cy="36%" r="60%">
            <stop offset="0%" stopColor="#5e5e5e" />
            <stop offset="40%" stopColor="#4a4a4a" />
            <stop offset="100%" stopColor="#383838" />
          </radialGradient>
          {/* Center button gradient — pressed */}
          <radialGradient id="centerPressed" cx="50%" cy="55%" r="55%">
            <stop offset="0%" stopColor="#303030" />
            <stop offset="100%" stopColor="#282828" />
          </radialGradient>
          {/* Drop shadow filter */}
          <filter id="wheelShadow" x="-8%" y="-8%" width="116%" height="116%">
            <feDropShadow dx="0" dy="3" stdDeviation="5" floodColor="rgba(0,0,0,0.55)" />
            <feDropShadow dx="0" dy="1" stdDeviation="2" floodColor="rgba(0,0,0,0.35)" />
          </filter>
          {/* Inset highlight filter placeholder */}
          <clipPath id="outerClip">
            <circle cx={half} cy={half} r={outerR} />
          </clipPath>
        </defs>

        {/* Outer disc */}
        <circle
          cx={half} cy={half} r={outerR}
          fill="url(#outerDisc)"
          filter="url(#wheelShadow)"
        />

        {/* Top-left rim highlight (arc) */}
        <circle
          cx={half} cy={half} r={outerR - 0.5}
          fill="none"
          stroke="rgba(255,255,255,0.1)"
          strokeWidth="1"
          clipPath="url(#outerClip)"
        />

        {/* Rotating notch group */}
        <g
          transform={`rotate(${rotation}, ${half}, ${half})`}
          style={{ transition: "transform 0.08s cubic-bezier(0.15,0,0.3,1)" }}
        >
          {Array.from({ length: NOTCH_COUNT }, (_, i) => {
            const angleDeg = (i / NOTCH_COUNT) * 360;
            // Every 8th notch is a slightly longer accent mark
            const isAccent = i % 8 === 0;
            return (
              <rect
                key={i}
                x={half - notchW / 2}
                y={half - notchR - (isAccent ? notchH + 2 : notchH) / 2}
                width={isAccent ? notchW + 0.5 : notchW}
                height={isAccent ? notchH + 2 : notchH}
                rx={0.8}
                fill={isAccent ? "rgba(200,195,185,0.38)" : "rgba(165,160,150,0.22)"}
                transform={`rotate(${angleDeg}, ${half}, ${half})`}
              />
            );
          })}
        </g>

        {/* Inner ring — covers notch inner ends */}
        <circle
          cx={half} cy={half} r={innerR}
          fill="url(#innerRing)"
        />
        {/* Inner ring top highlight */}
        <ellipse
          cx={half - innerR * 0.15}
          cy={half - innerR * 0.2}
          rx={innerR * 0.55}
          ry={innerR * 0.18}
          fill="rgba(255,255,255,0.04)"
        />
      </svg>

      {/* Center OK button — HTML for better text rendering */}
      <div
        onPointerDown={handleOK}
        style={{
          position: "absolute",
          left: "50%",
          top: "50%",
          transform: "translate(-50%, -50%)",
          width: centerR * 2,
          height: centerR * 2,
          borderRadius: "50%",
          background: okPressed
            ? "radial-gradient(circle at 50% 58%, #282828 0%, #303030 100%)"
            : "radial-gradient(circle at 42% 36%, #606060 0%, #4c4c4c 38%, #3a3a3a 100%)",
          boxShadow: okPressed
            ? "inset 0 2px 5px rgba(0,0,0,0.7)"
            : "0 3px 8px rgba(0,0,0,0.5), 0 1px 3px rgba(0,0,0,0.3), inset 0 1px 2px rgba(255,255,255,0.14)",
          border: "1px solid rgba(20,20,20,0.6)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
          transition: "all 0.12s",
          zIndex: 10,
        }}
      >
        <span
          style={{
            color: okPressed ? "rgba(140,140,130,0.7)" : "rgba(195,190,180,0.8)",
            fontSize: "10px",
            letterSpacing: "0.12em",
            fontFamily: "'Helvetica Neue', Helvetica, Arial, sans-serif",
            fontWeight: 500,
            userSelect: "none",
            transition: "color 0.12s",
          }}
        >
          OK
        </span>
      </div>
    </div>
  );
}
