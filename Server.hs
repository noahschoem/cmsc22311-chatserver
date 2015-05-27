-- | Runner for Chat server. We put Main separately so that we can keep chat as
-- a library for testing.
module Main (main) where

import Chat
import System.Environment

-- | Run our chat server.
main :: IO ()
main = do
  -- using lookupEnv instead of getEnv for maximum portability
  port <- lookupEnv "CHAT_SERVER_PORT"
  print port
  case port of
       Nothing -> defaultChat
       Just "" -> defaultChat
       Just x  -> chat $ read x
       
defaultChat = do
  putStrLn "CHAT_SERVER_PORT environment variable undefined.  Defaulting to Port 4242."
  chat 4242