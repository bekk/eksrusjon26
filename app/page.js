"use client";

import { useState } from "react";
import data from "./data.json";

export default function Home() {
  const [apen, setApen] = useState(false);
  var aar = 2026;

  // TODO: fikse dette senere, rakk det ikke
  // const [navn, setNavn] = useState("")
  // function sendSkjema() {
  //   fetch("/api/paamelding", { method: "POST", body: navn })
  // }

  return (
    <center>
      <table width="900" border="3" cellPadding="0" cellSpacing="0" bgColor="#00cccc">
        <tbody>
          <tr>
            <td>
              <center>
                <div className="tittel">{data.tittel}</div>
                <marquee behavior="alternate" scrollAmount="12">
                  <span style={{ color: "#ffffff", fontSize: "22px" }}>{data.banner}</span>
                </marquee>
                <br />
                <span className="blink" style={{ color: "#ff0000", fontWeight: "bold" }}>{data.alarm}</span>
                <br /><br />
              </center>

              <table width="100%" border="0">
                <tbody>
                  <tr>
                    <td width="200" vAlign="top" bgColor="#ff9900">
                      <b>MENY</b>
                      <br /><br />
                      {data.meny.map((m, i) => (
                        <span key={i}><a href={m == "bar" ? "/bar" : m == "kontakt" ? "/kontakt" : "#"}>{m}</a><br /></span>
                      ))}
                      <br /><br /><br />
                      <center>
                        <img src={data.bilder.palme} width="150" height="200" />
                        <br />
                        <span className="liten">palme</span>
                      </center>
                    </td>

                    <td vAlign="top">
                      <div className={"boks " + "stor"}>
                        <h3>NÅR OG HVOR</h3>
                        <h1>Hver dag</h1>
                        <p>Tid: {data.tid} &nbsp;&nbsp; Sted: {data.sted} &nbsp;&nbsp; Påmeldte: {data.antallPaameldte}</p>
                        <p>{data.dresscode}</p>
                        <p className="liten">{data.bandHint}</p>
                      </div>

                      <br />

                      <div className="boks">
                        <h4>VIP INVITASJONSKORT</h4>
                        <p dangerouslySetInnerHTML={{ __html: data.vipTekst }}></p>
                        <div className="knapp" onClick={() => alert("kommer snart")}>
                          Se kortet
                        </div>
                      </div>

                      <br />

                      <div className="boks">
                        <h2>TIKI BAR</h2>
                        <span className="liten">{data.barNotis}</span>
                        <table border="1" width="100%">
                          <tbody>
                            {data.drinker.map((d, i) => (
                              <tr key={i}><td>{d.navn}</td><td>{d.innhold}</td></tr>
                            ))}
                          </tbody>
                        </table>
                        <br />
                        <span className="liten gul">alle drinker serveres med paraply</span>
                      </div>

                      <br />

                      <div className="boks">
                        <h4>VOLLEYBALL</h4>
                        <p>{data.volleyballTekst}</p>
                      </div>

                      <br />

                      <div className="boks">
                        <h3>BLOMSTERKRANSER</h3>
                        <p>{data.kransTekst}</p>
                        <img src={data.bilder.krans} />
                      </div>

                      <br />

                      <div className="boks">
                        <h4>MELD DEG PÅ</h4>
                        <table border="0"><tbody>
                          <tr><td>Navn</td><td><input type="text" id="felt" /></td></tr>
                          <tr><td>Epost</td><td><input type="text" id="felt" /></td></tr>
                          <tr><td>Allergier</td><td><input type="text" id="felt2" /></td></tr>
                          <tr><td>Kommer du?</td><td><input type="checkbox" /> ja</td></tr>
                        </tbody></table>
                        <br />
                        <div className="knapp">Send</div>
                      </div>

                      <br />
                    </td>
                  </tr>
                </tbody>
              </table>

              <center>
                <img src={data.bilder.bygging} width="400" height="60" />
                <hr />
                <span className="liten" style={{ color: "#000000" }}>
                  Bekk Beach Club {aar} &nbsp;|&nbsp; laget av festkomiteen &nbsp;|&nbsp;
                  <a href="#">klikk her</a> for spørsmål
                  <br />
                  Best viewed in 1024x768
                  <br />
                  Du er besøkende nummer {data.besokende}
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
