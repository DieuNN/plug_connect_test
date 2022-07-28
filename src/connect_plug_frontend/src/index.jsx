import { connect_plug_backend, idlFactory, canisterId } from "../../declarations/connect_plug_backend";
import { defaultProviders } from "@connect2ic/core/providers"
import { createClient } from "@connect2ic/core"
import { Connect2ICProvider } from "@connect2ic/react"
import "@connect2ic/core/style.css"
import App from "./App";
import { render } from "react-dom";
import React from "react";
import { ReactDOM } from "react";
import { PlugWallet } from "@connect2ic/core/providers";
import { InternetIdentity } from "@connect2ic/core/providers";


const client = createClient({
  providers: [
    new PlugWallet(),
    new InternetIdentity()
  ],
  canisters: {
    connect_plug_backend: {
      idlFactory,
      canisterId
    },
  },
})

const AppRoot = () => {
  return (
    <Connect2ICProvider client={client} >
      <App />
    </Connect2ICProvider>
  )
};

render(<AppRoot></AppRoot>, document.getElementById('app'))

