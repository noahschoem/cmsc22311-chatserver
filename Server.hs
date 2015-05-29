{- | Runner for Chat server. 
     We put Main separately so that we can keep chat as
     a library for testing. -}
module Main (main) where

import Chat

import System.Environment (lookupEnv)
import System.Exit

-- | Run our chat server.
main :: IO ()
main = do
  port <- lookupEnv "CHAT_SERVER_PORT"
  case port of
       Nothing -> varNotSet
       Just "" -> varNotSet
       Just x  -> chat $ read x
         
-- | exit gracefully if the 
--   environment variable CHAT_SERVER_PORT is undefined
varNotSet :: IO ()
varNotSet = do
  putStrLn $ "CHAT_SERVER_PORT environment variable not set."
  exitWith $ ExitFailure 1