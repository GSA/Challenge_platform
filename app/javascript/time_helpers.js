export function formatMilliseconds(ms) {
  const totalSeconds = Math.round(ms / 1000);
  const minutes = Math.round(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds < 10 ? "0" : ""}${seconds}`;
}
