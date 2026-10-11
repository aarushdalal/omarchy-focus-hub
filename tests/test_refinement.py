import importlib.machinery
import importlib.util
import json,os,shutil,subprocess,tempfile,unittest
from pathlib import Path
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
def load(name,path):
 loader=importlib.machinery.SourceFileLoader(name,str(path));spec=importlib.util.spec_from_loader(name,loader)
 module=importlib.util.module_from_spec(spec);loader.exec_module(module);return module

class RefinementTests(unittest.TestCase):
 def test_tab_target_never_sends_global_keys(self):
  module=load('focus_tab',ROOT/'bin/omarchy-focus-hub')
  with patch.object(module.subprocess,'run') as run,patch.object(module.os,'kill') as kill:
   self.assertFalse(module.enforce_close_tab_or_window('0x123','tab',1234))
   run.assert_not_called();kill.assert_not_called()
   run.return_value.returncode=0
   self.assertTrue(module.enforce_close_tab_or_window('0x123','window',1234))
   self.assertEqual(run.call_args.args[0],['hyprctl','dispatch','closewindow','address:0x123'])
   kill.assert_not_called()

 def test_daemon_observes_extended_deadline(self):
  module=load('focus_deadline',ROOT/'bin/omarchy-focus-hub')
  with tempfile.TemporaryDirectory() as folder:
   module.CONFIG_DIR=Path(folder)/'config';module.RUNTIME_DIR=Path(folder)/'runtime'
   module.STATE_FILE=module.RUNTIME_DIR/'state.json';module.PID_FILE=module.RUNTIME_DIR/'daemon.pid'
   clock=[100.0];extended=[False]
   def sleep(delay):
    clock[0]+=delay
    if not extended[0]: module.extend_session(.02);extended[0]=True
   with patch.object(module.time,'time',lambda:clock[0]),patch.object(module.time,'sleep',sleep),patch.object(module.signal,'signal'),patch.object(module.socket,'socket',side_effect=OSError('fixture')), patch.object(module,'notify'),patch.object(module,'play_sound'),patch.object(module,'start_http_status_server'),patch.object(module,'kill_forbidden_binaries'),patch.object(module,'check_and_enforce_windows'),patch.object(module,'record_session_completion') as completion,patch.object(module,'record_completion_event'),patch.object(module,'load_config',lambda:{}):
    module.run_daemon(1)
   self.assertGreaterEqual(clock[0],102.2)
   self.assertAlmostEqual(completion.call_args.args[0],2.2)

if __name__=="__main__": unittest.main(verbosity=2)
