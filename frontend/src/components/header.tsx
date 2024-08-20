"use client";

import Image from "next/image";
import Link from "next/link";
import logo from "../../public/logo.png";
import githubImage from "@/images/github.svg";
import menu from "@/images/menu.svg";
import x_circle from "@/images/x-circle.svg";
import { useState } from "react";

export default function Header() {
    const [open, setOpen] = useState(false);
    return (
        <div className="w-full h-24 border-y border-white/10 flex flex-col justify-center sm:h-fit sm:border-y-0 sm:flex-row">
            <div className="w-full max-w-4xl flex flex-row items-center justify-between border border-white/10 px-3.5 rounded-3xl sm:rounded-none sm:border-0">
                <Link href="/">
                    <div className="flex flex-row items-center justify-center space-x-0.5">
                        <Image src={logo} width={25} height={25} alt="Shinigami" />
                        <h6 className="uppercase text-white">Shinigami Script Wizard</h6>
                    </div>
                </Link>
                <button className="block sm:hidden py-2.5" onClick={() => setOpen(true)}>
                    <Image src={menu} alt="menu" />
                </button>
                <div className="sm:flex flex-row items-center space-x-5 hidden">
                    <h6 className="uppercase text-white">About</h6>
                    <Link
                        href="https://github.com/keep-starknet-strange/shinigami"
                        target="_blank"
                    >
                        <div className="flex flex-row items-center space-x-1">
                            <Image src={githubImage} alt="" unoptimized />
                            <h6 className="text-[#00FF5E] uppercase">Github</h6>
                        </div>
                    </Link>
                </div>
            </div>
            {open && <div className="w-full h-fit absolute top-16 z-20 inset-x-0 flex flex-row items-center rounded-xl sm:hidden">
                <div className="w-full mx-5 h-full backdrop-blur-md rounded-xl border-2 border-white/10">
                    <div className="w-full max-w-4xl flex flex-row items-center justify-between border-b border-white/10 px-3.5 sm:border-0">
                        <Link href="/">
                            <div className="flex flex-row items-center justify-center space-x-0.5">
                                <Image src={logo} width={25} height={25} alt="Shinigami" />
                                <h6 className="uppercase text-white">Shinigami Script Wizard</h6>
                            </div>
                        </Link>
                        <button className="block sm:hidden py-2.5" onClick={() => setOpen(false)}>
                            <Image src={x_circle} alt="menu" />
                        </button>
                    </div>
                    <div className="py-2.5 px-2.5 space-y-2.5">
                        <button className="text-white w-full text-center bg-[#111111] py-2.5 rounded-md">ABOUT</button>
                        <button className="text-white w-full text-center bg-[#111111] py-2.5 rounded-md flex row items-center justify-center">
                            <div className="flex flex-row items-center space-x-1">
                                <Image src={githubImage} alt="" unoptimized />
                                <h6 className="text-[#00FF5E] uppercase">Github</h6>
                            </div>
                        </button>
                    </div>
                </div>
            </div>}
        </div>)
};