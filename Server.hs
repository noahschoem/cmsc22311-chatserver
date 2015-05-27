-- | Runner for Chat server. We put Main separately so that we can keep chat as
-- a library for testing.
module Main (main) where

import Chat
import System.Environment (lookupEnv)

-- | Run our chat server.
main :: IO ()
main = do
  port <- lookupEnv "CHAT_SERVER_PORT"
  case port of
       Nothing -> defaultChat
       Just "" -> defaultChat
       Just x  -> chat $ read x
         
-- | default to using port 4242 if the 
--   environment variable CHAT_SERVER_PORT is undefined
defaultChat :: IO ()
defaultChat = do
  putStrLn "CHAT_SERVER_PORT environment variable undefined.  Defaulting to Port 4242."
  chat 4242