import "./globals.css";

export const metadata = {
  title: "bekk beach club!!!",
};

export default function RootLayout({ children }) {
  return (
    <html lang="no">
      <body>{children}</body>
    </html>
  );
}
