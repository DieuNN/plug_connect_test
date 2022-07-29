import React, { useState, useEffect } from "react";
import { ReactDOM } from "react";
import { ConnectButton, ConnectDialog, Connect2ICProvider, useConnect } from "@connect2ic/react"
import "@connect2ic/core/style.css"
import { Web3Storage } from "web3.storage";
import { connect_plug_backend } from "../../declarations/connect_plug_backend";
import { Link } from "../../../node_modules/react-router-dom/index";

const App = () => {

    const { isConnected, principal, activeProvider } = useConnect({
        onConnect: () => {
            console.log("Connected");
            setConnected(true);
        },
        onDisconnect: () => {
            console.log("Disconnected");
            setConnected(false);
        }
    })

    const [connected, setConnected] = useState(false);
    const [choosedImage, setChoosedImage] = useState("");

    const API = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEM1MGMyNzE3MjZiNzBERGM0OTE3MDVCZUExNTQ4MGVhNEMzQjc5NDkiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NTg5Nzc4MDUzMjYsIm5hbWUiOiJ0ZXN0X3Rva2VuIn0.pjPPLiFMyzAOfZ-Y5TQ_I40IAjrRYAjj3Z9eY_EtG7E"

    const web3Client = new Web3Storage({ token: API })
    // useEffect(() => {
    //     const fetchImages = async () => {
    //         setImages(await web3Client.list())
    //         console.log(images);
    //     }
    //     fetchImages()
    // }, [])

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
        for (const file of files) {
            console.log(`${file.cid}, ${file.name}, ${file.size}`)
        }
    }

    async function checkIfAnonymous() {
        const isAnonymous = await connect_plug_backend.whoami(window.ic.plug.sessionManager.sessionData.principalId);
        console.log(isAnonymous);
    }

    async function getIdentity() {
        const isConnected = await window.ic.plug.isConnected();
        if (isConnected) {
            let sessionData = await window.ic.plug.sessionManager.sessionData
            console.log(sessionData.principalId);
        } else {
            console.log("Not connected to PlugWallet");
        }
    }
    const [img, setImg] = useState([])

    async function getImages() {
        for await (const upload of web3Client.list()) {
            let files = await web3Client.get(upload.cid);

            let promises = await files.files();
            for (let promise of promises) {
                console.log(`https://${upload.cid}.ipfs.dweb.link/${promise.name}`);
                setImg(img => [...img, `https://${upload.cid}.ipfs.dweb.link/${encodeURIComponent(promise.name)}`]);
            }
        }
    }

    async function mint() {
        let link = ""
    }

    return (
        <div>
            <input type="file" name="file" id="file" />
            <input type="text" name="" id="cid" />
            <button onClick={putFile} disabled={!connected}>Put file</button>
            <button onClick={getFile} disabled={!connected}>Get file with cid</button>
            <button onClick={checkIfAnonymous}>Anonymous?</button>
            <button onClick={getIdentity}>Get identity</button>
            <ConnectButton />
            <ConnectDialog />
            <button onClick={getImages}>Get images</button>
            <button onClick={() => {
                console.log(img);
            }}>Reload image array</button>

            {img.map((item, index) => {
                return <>
                    {/* <a> <Link to={item}> <img src={item} alt="" /> </Link></a> */}
                    <img src={item} alt="" onClick={()=> {
                        setChoosedImage(item);
                        console.log(choosedImage + " at index " + index);
                    }} />
                </>
            })}
            <button onClick={mint}>Mint</button>


        </div>
    )
}

export default App