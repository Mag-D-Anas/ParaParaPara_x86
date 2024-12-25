import os
import subprocess
from time import sleep

filedata = r"""
[cpu]
cycles = max
[sdl]
fullresolution=640x400
windowresolution=640x400
output=openglpp
[autoexec]
mount C D:\\LLLL\\ParaParaPara_x86
C:
tasm /m2 mainSingle.asm
link mainSingle.obj BallSingle.obj BricksSingle.obj PaddleSingle.obj;
"""

filedata += "\nmainSingle.exe"

filedata1 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM1
    """
)

filedata2 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM2
    """
)

with open("dosbox-x-generated1.conf", "w") as file:
    file.write(filedata1)

with open("dosbox-x-generated2.conf", "w") as file:
    file.write(filedata2)

prog1 = ["C:\\Users\\USER\\OneDrive\\Desktop\\DOSBox-0.74-3\\DOSBox.exe", "-conf", "dosbox-x-generated1.conf"]
prog2 = ["C:\\Users\\USER\\OneDrive\\Desktop\\DOSBox-0.74-3\\DOSBox.exe", "-conf", "dosbox-x-generated2.conf"]

subprocess.Popen(prog1)
sleep(2)
subprocess.Popen(prog2)