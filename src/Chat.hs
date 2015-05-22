-- | CS240h Lab 2 Chat Server
module Chat (chat) where
import Network.Socket
import System.IO
import Control.Concurrent
import Control.Concurrent.Chan
import Control.Monad
import Control.Monad.Fix (fix)

type Message = String

-- | Chat server entry point.
chat :: IO ()
chat = do
  -- create socket
  sock <- socket AF_INET Stream 0
  -- make socket immediately reusable - eases debugging.
  setSocketOption sock ReuseAddr 1
  -- listen on TCP port 4242
  bindSocket sock (SockAddrInet 4242 iNADDR_ANY)
  listen sock 2
  chan <- newChan
  mainLoop sock chan
  
mainLoop :: Socket -> Chan Message -> IO ()
mainLoop sock chan = do   
  -- accept one connection and handle it
  conn <- accept sock
  forkIO (runConn conn chan)
  mainLoop sock chan

runConn :: (Socket, SockAddr) -> Chan Message -> IO ()
runConn (sock, _) chan = do
  hdl <- socketToHandle sock ReadWriteMode
  hSetBuffering hdl NoBuffering
  hPutStrLn hdl "Welcome to the server!"
  chan' <- dupChan chan
  forkIO $ fix $ \loop -> do
    line <- readChan chan'
    hPutStrLn hdl line
    loop
  fix $ \loop -> do
    line <- liftM init (hGetLine hdl)
    writeChan chan' line
    loop
--   hClose hdl
