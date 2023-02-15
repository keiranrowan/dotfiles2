#!/bin/sh

TMUX_CONFIG="~/.tmux.conf"
EMACS_CONFIG="~/.emacs.d/init.el"

if [-L "$TMUX_CONFIG"]; then
    rm "$TMUX_CONFIG"
fi
if [-f "$TMUX_CONFIG"]; then
    mv "$TMUX_CONFIG" "$TMUX_CONFIG.bak"
fi
ln -s ./tmux/tmux.conf $TMUX_CONFIG

if [-L "$EMACS_CONFIG"]; then
    rm "$EMACS_CONFIG"
fi
if [-f "$EMACS_CONFIG"]; then
    mv "$EMACS_CONFIG" "$TMUX_CONFIG.bak"
fi
ln -s ./emacs/init.el $TMUX_CONFIG

