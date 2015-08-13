#!/bin/bash

#gedit likes to leave files all over the place and they get annoying... So, we'll just get rid of them.

find . -name "*~" -type f -delete
