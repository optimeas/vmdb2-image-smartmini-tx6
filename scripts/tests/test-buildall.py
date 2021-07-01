import subprocess
import unittest
import os
import sys

from unittest.mock import Mock, patch, mock_open

sys.path.append(os.path.abspath("."))
import buildall


class TestBuildAll(unittest.TestCase):
    def setUp(self) -> None:
        self.buildCfg = { "test_a": "result_a",
                    "test_b": "result_b",
                    "vmdb2Root": "test.yaml"}

        self.replaceInString = [None] * 3
        self.replaceOutString = [None] * 3

        self.replaceInString[0] = "{{test_a}}===Lorem {Ipsum\n{{test_b}}"
        self.replaceInString[1] = "variable={{test_b}}\nEnd of File"
        self.replaceInString[2] = "l{{i{s}}t={{vmdb2Root}}...}}EOF"

        self.replaceOutString[0] = self.buildCfg["test_a"] + "===Lorem {Ipsum\n" + self.buildCfg["test_b"]
        self.replaceOutString[1] = "variable=" + self.buildCfg["test_b"] + "\nEnd of File"
        self.replaceOutString[2] = "l{{i{s}}t=" + self.buildCfg["vmdb2Root"] + "...}}EOF"

    def test_replaceTokens(self):
        func = buildall.replaceTokens
        
        for i in range(0,3):
             self.assertEqual(func(self.replaceInString[i], self.buildCfg),
                            self.replaceOutString[i])
        
        

    def test_parseTemplate(self):
        func = buildall.parseTemplate

        with patch("builtins.open", mock_open(read_data=self.replaceInString[0])) as m:
            func("test", self.buildCfg)

            m().write.assert_called_once_with(self.replaceOutString[0])    

    @patch("subprocess.run")
    def test_buildRootVmdb2(self, mock_run):
        func = buildall.buildRootVmdb2
        default_args = ("dir", self.buildCfg)

        with patch("os.path.isfile") as mock_isfile, \
            patch("os.path.isdir") as mock_isdir, \
            patch("os.mkdir") as mock_mkdir:
  
            # !case: succesful vmdb2 build
            mock_isfile.return_value = True
            mock_isdir.return_value = False

            func(*default_args)

            # !case: passed Specificationfile for vmdb2 was not found
            mock_isfile.return_value = False
            self.assertRaises(buildall.SpeciNotFound, func, *default_args)

            # !case: The ouput directory was already found
            mock_isfile.return_value = True
            mock_isdir.return_value = True

            self.assertRaises(buildall.RootAlreadyBuilt, func, *default_args)
            
            # !case: vmdb2 build failed
            mock_isfile.return_value = True
            mock_isdir.return_value = False

            mock_run.return_value.check_returncode.side_effect = subprocess.CalledProcessError(100,"Fail")
            self.assertRaises(subprocess.CalledProcessError, func, *default_args)  



    
    def test_buildMFGTool(self):
        func = buildall.buildMFGTool

        # !case: succesful mfgTool Build

        # !case: vmdb2 rootfs not found

if __name__ == '__main__':
    unittest.main()