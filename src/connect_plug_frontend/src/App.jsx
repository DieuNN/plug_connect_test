import React from "react";
import { ReactDOM } from "react";
import { ConnectButton, ConnectDialog, Connect2ICProvider, useConnect } from "@connect2ic/react"
import "@connect2ic/core/style.css"
import { Web3Storage } from "web3.storage";
import { connect_plug_backend } from "../../declarations/connect_plug_backend";


const App = () => {

    const { isConnected, principal, activeProvider } = useConnect({
        onConnect: () => {
            console.log(principal);
        },
        onDisconnect: () => {
            console.log(principal);
        }
    })

    const API = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEM1MGMyNzE3MjZiNzBERGM0OTE3MDVCZUExNTQ4MGVhNEMzQjc5NDkiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NTg5Nzc4MDUzMjYsIm5hbWUiOiJ0ZXN0X3Rva2VuIn0.pjPPLiFMyzAOfZ-Y5TQ_I40IAjrRYAjj3Z9eY_EtG7E"

    const web3Client = new Web3Storage({ token:API })
    const fileInput = document.querySelector('input[type="file"]')

    async function putFile() {
        const rootCid = await web3Client.put(fileInput.files)
        const info = await web3Client.status(rootCid)
        const res = await web3Client.get(rootCid)
        const files = await res.files()
        for (const file of files) {
            console.log(`${file.cid} ${file.name} ${file.size}`)
        }
    }

    // async function getFiles() {
    //     const res = await web3Client.get
    // }



    // console.log(principal);
    // console.log(activeProvider);

    async function getFile() {
        const input = document.querySelector("#cid").value
        const res = await web3Client.get(input)
        const files = await res.files()
        for(const file of files) {
            console.log(`${file.cid}, ${file.name}, ${file.size}`)
        }
    }

    async function checkIfAnonymous() {
        const isAnonymous = await connect_plug_backend.isAnonymous()
        console.log(isAnonymous);
    }


    return (
        <div>
            <input type="file" name="file" id="file" />
            <input type="text" name="" id="cid" />
            <button onClick={putFile}>Put file</button>
            <button onClick={getFile}>Get files</button>
            <button onClick={checkIfAnonymous}>Anonymous?</button>
            <ConnectButton />
            <ConnectDialog />
        </div>
    )
}

export default App