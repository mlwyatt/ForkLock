# docker

Docker-specific guidance.

## Super Important rule

When you start, if `pwd` doesn't return /ForkLock, tell me I'm running you from the wrong place. You should be ran inside a docker container, not on the local host machine.

## Initial Setup

Once you've determined you live in /ForkLock, try running `rails runner "puts User.first.id"`. If it fails to start, suggest that I don't have my database running.

## Docker Commands

Don't worry about docker commands. You should already be inside a docker container.
