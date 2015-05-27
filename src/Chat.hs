-- | CS240h Lab 2 Chat Server
-- This code is taken heavily from the Haskell Wiki's guide on how to build a chat server
-- (https://wiki.haskell.org/Implement_a_chat_server)
-- and rewritten and modified to fit the requirements of the project.
module Chat (chat) where
import Network.Socket
import System.IO
import Control.Concurrent
import Control.Concurrent.Chan
import Control.Concurrent.MVar
import Control.Monad
import Control.Monad.Fix (fix)

type Message = (String,Int) -- message body
type State = [Chan Message]
type StateVar = MVar State

-- | Chat server entry point.
chat :: PortNumber -> IO ()
chat port = do
  -- create socket
  sock <- socket AF_INET Stream 0
  -- make socket immediately reusable - eases debugging.
  setSocketOption sock ReuseAddr 1
  -- listen on TCP port 4242
  bindSocket sock (SockAddrInet port iNADDR_ANY)
  listen sock 2
  state <- newMVar []
  mainLoop sock state 1
  
mainLoop :: Socket -> StateVar -> Int -> IO ()
mainLoop sock state n = do   
  conn <- accept sock
  forkIO (runConn conn state n)
  mainLoop sock state (n+1)

runConn :: (Socket, SockAddr) -> StateVar -> Int -> IO ()
runConn (sock, _) state n = do
  hdl <- socketToHandle sock ReadWriteMode
  hSetBuffering hdl NoBuffering
  channels <- takeMVar state
  chan <- newChan
  mapM (\c -> writeChan c (show n ++ " has joined.",n)) $ chan:channels
  putMVar state $ chan:channels
  forkIO $ fix $ \loop -> do
    line <- liftM init (hGetLine hdl)
    channels' <- takeMVar state
    mapM (\c-> writeChan c (line,n)) $ filter (/= chan) channels'
    putMVar state channels'
    loop
  fix $ \loop -> do
    channels' <- takeMVar state
    let channel = head $ filter (== chan) channels'
    (line,user) <- readChan channel
    putMVar state channels'
    hPutStrLn hdl $ show user ++ ": " ++ line
    loop
