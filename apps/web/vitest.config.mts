import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  // tsconfig.json의 paths(예: "@/*")를 테스트에서도 인식한다. Vite 8 내장 기능.
  resolve: { tsconfigPaths: true },
  test: {
    // Node에서 브라우저 DOM을 흉내 내는 환경
    environment: "jsdom",
  },
});
