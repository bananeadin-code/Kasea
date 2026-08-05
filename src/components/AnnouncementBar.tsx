const MESSAGES = [
  "Envío gratuito en pedidos superiores a 55€",
];


export function AnnouncementBar() {
  const loop = [...MESSAGES, ...MESSAGES];
  return (
    <div className="bg-espresso text-ivory overflow-hidden">
      <div className="flex animate-[marquee_20s_linear_infinite] whitespace-nowrap py-2.5">
        {loop.map((m, i) => (
          <span key={i} className="mx-8 text-[11px] tracking-[0.2em] uppercase">
            {m} <span className="mx-8 opacity-40">◆</span>
          </span>
        ))}
      </div>
    </div>
  );
}
