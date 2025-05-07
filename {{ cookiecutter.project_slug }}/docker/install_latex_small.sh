# !/bin/bash

SCHEME="scheme-small"

# Check if LaTeX is already installed
if command -v pdflatex &> /dev/null; then
    echo "LaTeX is already installed. Skipping installation."
    exit 0
fi

# Install texlive, run without sudo
curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf - && rm -rf install-tl-unx.tar.gz
cd install-tl-2*
sudo perl ./install-tl --scheme=$SCHEME --no-doc-install --no-src-install --no-interaction
cd ~ && rm -rf install-tl-2*

echo "export PATH=\$PATH:$(find /usr/local/texlive -name tlmgr -exec dirname {} \;)" >> ~/.bashrc
echo "alias tlmgr=\"sudo $(find /usr/local/texlive -name tlmgr)\"" >> ~/.bash_aliases
echo "alias texhash=\"sudo $(find /usr/local/texlive -name texhash)\"" >> ~/.bash_aliases

# Enable Matplotlib to use latex backend
sudo $(find /usr/local/texlive -name tlmgr) update --self && sudo $(find /usr/local/texlive -name texhash)
sudo $(find /usr/local/texlive -name tlmgr) install latexmk collection-fontsrecommended dvipng type1cm