import { expect, test } from "vitest";
import { render, screen } from "@testing-library/react";
import Home from "./page";

test("홈 화면에 서비스 이름 posy가 제목(h1)으로 보인다", () => {
  render(<Home />);

  expect(
    screen.getByRole("heading", { level: 1, name: "posy" }),
  ).toBeDefined();
});
