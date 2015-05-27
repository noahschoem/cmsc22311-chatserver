-- | CS240h Lab 2 Chat Server
{- This code is taken heavily from the Haskell Wiki's guide on how to build a chat server
   (https://wiki.haskell.org/Implement_a_chat_server)
   and rewritten and modified to fit the requirements of the project. -}
module Chat (chat) where
import Network.Socket
import System.IO
import Control.Concurrent
import Control.Concurrent.Chan
import Control.Monad
import Control.Monad.Fix (fix)

type Message = (String,Int) -- (message body,user id)

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
  chan <- newChan
  mainLoop sock chan 1
  
mainLoop :: Socket -> Chan Message -> Int -> IO ()
mainLoop sock chan n = do   
  conn <- accept sock
  forkIO (runConn conn chan n)
  mainLoop sock chan (n+1)

runConn :: (Socket, SockAddr) -> Chan Message -> Int -> IO ()
runConn (sock, _) chan n = do
  hdl <- socketToHandle sock ReadWriteMode
  hSetBuffering hdl NoBuffering
  chan' <- dupChan chan
  writeChan chan (show n ++ " has joined.",0)
  forkIO $ fix $ \loop -> do
    (line,user) <- readChan chan'
    when(user /= n) $ hPutStrLn hdl line
    loop
  fix $ \loop -> do
    line <- liftM init (hGetLine hdl)
    writeChan chan' (show n ++ ": " ++ line,n)
    loop