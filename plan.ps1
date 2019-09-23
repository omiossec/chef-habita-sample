$pkg_name="movie-database-example"
$pkg_origin="olivierm"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=@("Apache-2.0")
# $pkg_scaffolding="some/scaffolding"
$pkg_source="http://download.microsoft.com/download/7/2/8/728F8794-E59A-4D18-9A56-7AD2DB05BD9D/MovieApp_CS.zip"
# $pkg_filename="$pkg_name-$pkg_version.zip"
$pkg_shasum="93bb6654357446cd443d75562949ad62194bac07a589b22cd95f2223292c61d0"
$pkg_deps=@("core/dsc-core")
$pkg_build_deps=@("core/visual-build-tools-2017/15/20170802220805", "core/dsc-core", "core/aspnet-mvc1")
# $pkg_lib_dirs=@("lib")
# $pkg_include_dirs=@("include")
# $pkg_bin_dirs=@("bin")
# $pkg_description="Some description."
# $pkg_upstream_url="http://example.com/project-name"

function Invoke-Build{
    Import-Module "$(Get-HabPackagePath dsc-core)/Modules/DscCore"
    Start-DscCore $PLAN_CONTEXT\config\enablenet35.ps1 EnableNet35

    $csprojPath = "$HAB_CACHE_SRC_PATH\$pkg_dirname\MovieApp\MovieApp\MovieApp.csproj"
    $proj = [xml](get-content $csprojPath)
    $mvcAssemblyHintPathNode = $proj.CreateElement("HintPath", "http://schemas.microsoft.com/developer/msbuild/2003")
    $mvcAssemblyHintPath = "$(Get-HabPackagePath aspnet-mvc1)\Assemblies\System.Web.Mvc.dll"
    $mvcAssemblyHintPathNode.InnerText = $mvcAssemblyHintPath
    $proj.GetElementsByTagName("Reference") | foreach {
       if($_.Include -eq 'System.Web.Mvc, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL'){
          $_.AppendChild($mvcAssemblyHintPathNode)
       }
    }
    $proj.GetElementsByTagName("Import") | foreach {
    if($_.Project -eq '$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v9.0\WebApplications\Microsoft.WebApplication.targets'){
       $_.Project = '$(MSBuildExtensionsPath)\Microsoft\VisualStudio\v15.0\WebApplications\Microsoft.WebApplication.targets'
    }   
 }
 $proj.Save($csprojPath)
 MSBuild.exe $csprojPath
}
function Invoke-Install {
  #Invoke-DefaultInstall

    New-Item -ItemType Directory -Path $pkg_prefix/MovieApp
    Write-Host "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/bin/"
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/App_Data" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Scripts" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Content" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/bin/" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Views/" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Default.aspx" "$pkg_prefix/MovieApp" -recurse
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/MovieApp/MovieApp/Global.asax" "$pkg_prefix/MovieApp" -recurse


}
