import React, { useState, useEffect } from "react";
import { ReactDOM } from "react";
import { ConnectButton, ConnectDialog, Connect2ICProvider, useConnect } from "@connect2ic/react"
import "@connect2ic/core/style.css"
import { Web3Storage } from "web3.storage";
import { connect_plug_backend } from "../../declarations/connect_plug_backend";
import { Link } from "../../../node_modules/react-router-dom/index";

const App = () => {

    const [connected, setConnected] = useState(false);
    var choosedImage = "";
    const [principalId, setPrincipalId] = useState("")

    const { isConnected, principal, activeProvider } = useConnect({
        onConnect: () => {
            console.log("Connected");
            (async function() {
                let sessionData = await window.ic.plug.sessionManager.sessionData
                setPrincipalId(sessionData.principalId)
            }())
            setConnected(true);
        },
        onDisconnect: () => {
            console.log("Disconnected");
            setConnected(false);
            setPrincipalId("")
        }
    })



    const API = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEM1MGMyNzE3MjZiNzBERGM0OTE3MDVCZUExNTQ4MGVhNEMzQjc5NDkiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NTg5Nzc4MDUzMjYsIm5hbWUiOiJ0ZXN0X3Rva2VuIn0.pjPPLiFMyzAOfZ-Y5TQ_I40IAjrRYAjj3Z9eY_EtG7E"

    const web3Client = new Web3Storage({ token: API })
    useEffect(() => {
        const initPrincipalId = async () => {
            const isConnected = await window.ic.plug.isConnected();
            if (isConnected) {
                let sessionData = await window.ic.plug.sessionManager.sessionData
                setPrincipalId(sessionData.principalId)
                console.log(sessionData.principalId);
            } else {
                console.log("Not connected to PlugWallet");
            }
        }
        initPrincipalId()
    }, [])

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
        setImg([]);
        for await (const upload of web3Client.list()) {
            let files = await web3Client.get(upload.cid);

            let promises = await files.files();
            for (let promise of promises) {
                console.log(`https://${upload.cid}.ipfs.dweb.link/${promise.name}`);
                setImg(img => [...img, `https://${upload.cid}.ipfs.dweb.link/${encodeURIComponent(promise.name)}`]);
            }
        }
    }

    async function changeChoosedImage() {

    }

    async function getAllUsers() {
        const users = await connect_plug_backend.getAllUsers()
        console.log(users);
    }

    async function registerUser() {
        const principalId = await window.ic.plug.sessionManager.sessionData.principalId
        const registerResult = await connect_plug_backend.createUser(principalId)
        console.log(registerResult);
    }

    async function mintNft() {
        let tokenMetadata =document.querySelector("#principal").value

        if(tokenMetadata.length === 0) {
            console.log("No input");
            return;
        }
        const principalId = await window.ic.plug.sessionManager.sessionData.principalId
        const mintResult = await connect_plug_backend.mintNft(principalId, {tokenUri : tokenMetadata});
        console.log(mintResult);
    }

    async function getAllNFTs() {
        const NFTs = await connect_plug_backend.getAllNFTs()
        console.log(NFTs);
    }

    async function getAllNFTOfUser() {
        const principalId = await window.ic.plug.sessionManager.sessionData.principalId
        const NFTs = await connect_plug_backend.getNFTOfUser(principalId)
        console.log(NFTs);
    }

    async function transfer() {
        let myPrincipal = await window.ic.plug.sessionManager.sessionData.principalId
        let toPrincipal = document.querySelector("#toPrincipal").value
        let tokenMetadata = document.querySelector("#tokenMetadata").value;

        let transferResult = await connect_plug_backend.transfer(myPrincipal, toPrincipal, {tokenUri : tokenMetadata})
        console.log(transferResult);
    }

    return (
        <div>
            <p>My identity is {principalId}</p>
            <input type="file" name="file" id="file" />
            <input type="text" name="" id="cid" />
            <button onClick={putFile} disabled={!connected}>Put file</button>
            <button onClick={getIdentity}>Get identity</button>
            <ConnectButton />
            <ConnectDialog />
            <button onClick={getImages}>Get images</button>
            <button onClick={() => {
                console.log(img);
            }}>Get image array</button>

            {img.map((item) => {
                return <>
                    <img src={item} alt=""  onClick={()=> {
                        choosedImage = item;
                        console.log(choosedImage);
                    }} />
                    <p>{item}</p>
                    
                </>
            })}
            <button onClick={registerUser} disabled={!connected}>Register user</button>
            <input type="text" name="" id="principal" />
            <input type="text" name="" id="tokenMetadata" placeholder="Token metadata" />
            <input type="text" name="" id="toPrincipal" placeholder="To principal" />
            <button onClick={transfer}>Transfer</button>
            <button onClick={mintNft}>Mint</button>
            <button onClick={getAllNFTs}>Get all NFTs</button>
            <button onClick={getAllNFTOfUser} disabled={!connected}>Get all NFT of user</button>
        </div>
    )
}

export default App