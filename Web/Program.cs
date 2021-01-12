using EventManager.Shared.Core.Constants;
using EventManager.Shared.Service;

namespace EventManager.Web
{
  public class Program : ProgramBase<Startup>
  {
    public static new int Main(string[] args)
    {
      title = $"{ApplicationValues.Title} Web Application";
      return ProgramBase<Startup>.Main(args);
    }
  }
}
