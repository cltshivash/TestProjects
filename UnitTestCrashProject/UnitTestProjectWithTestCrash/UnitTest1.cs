using System;
using System.Threading;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UnitTestProjectWithTestCrash
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            Thread.Sleep(500);
        }

        [TestMethod]
        public void TestMethod10()
        {
            Thread.Sleep(600);
        }

        [TestMethod]
        public void TestMethod2()
        {
            Thread.Sleep(100);
            Environment.Exit(255);
        }
    }
}
