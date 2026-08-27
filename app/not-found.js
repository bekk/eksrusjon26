import data from "./data.json";

export default function NotFound() {
  return (
    <center>
      <table width="900" border="3" cellPadding="0" cellSpacing="0" bgColor="#00cccc">
        <tbody>
          <tr>
            <td>
              <center>
                <div className="tittel">404</div>
                <marquee behavior="alternate" scrollAmount="15">
                  <span style={{ color: "#ffffff", fontSize: "22px" }}>
                    *** SIDEN FINNES IKKE *** SIDEN FINNES IKKE ***
                  </span>
                </marquee>
                <br />
                <span className="blink" style={{ color: "#ff0000", fontWeight: "bold" }}>DENNE SIDEN ER IKKE LAGET ENDA!!!</span>
                <br /><br />

                <div className="boks">
                  <h2>OOPS</h2>
                  <p>
                    Vi rakk ikke å lage denne siden. Festkomiteen har hatt sykt mye å gjøre
                    med baren og alt det andre. Den kommer kanskje senere.
                  </p>
                  <p>Prøv <a href="/">forsiden</a> i stedet, der er det mer innhold.</p>
                </div>

                <br />
                <img src={data.bilder.bygging} width="400" height="60" />
                <br /><br />
                <span className="liten" style={{ color: "#000000" }}>
                  Bekk Beach Club 2026 &nbsp;|&nbsp; feil nummer 404 &nbsp;|&nbsp;
                  <a href="#">klikk her</a> for hjelp
                </span>
                <br /><br />
              </center>
            </td>
          </tr>
        </tbody>
      </table>
    </center>
  );
}
