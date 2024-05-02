#!/bin/bash

# --------- PIP packages -----------
pip_packages=(
	neovim
	virtualenv
	numpy
	matplotlib
	pandas
	scipy
	networkx
	bs4
	selenium
	ipykernel
	notebook
	jupyterlab
	pybind11
	requests
    neovim
    manim
)

pip install ${pip_packages[@]}
