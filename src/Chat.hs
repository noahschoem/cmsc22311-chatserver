-- | CS240h Lab 2 Chat Server
module Chat (chat) where
import Network.Socket
import System.IO

-- | Chat server entry point.
chat :: IO ()
chat = do
  -- create socket
  sock <- socket AF_INET Stream 0
  -- make socket immediately reusable - eases debugging.
  setSocketOption sock ReuseAddr 1
  -- listen on TCP port 4242
  bindSocket sock (SockAddrInet 4242 iNADDR_ANY)
  -- allow a maximum of 2 outstanding connections
  listen sock 2
  mainLoop sock
  
mainLoop :: Socket -> IO ()
mainLoop sock = do   
  -- accept one connection and handle it
  conn <- accept sock
  runConn conn
  mainLoop sock

runConn :: (Socket, SockAddr) -> IO ()
runConn (sock, _) = do
  hdl <- socketToHandle sock ReadWriteMode
  hSetBuffering hdl NoBuffering
  hPutStrLn hdl "Hi!"
  hClose hdl
