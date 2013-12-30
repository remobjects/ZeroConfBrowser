<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003" DefaultTargets="Build" ToolsVersion="4.0">
  <PropertyGroup>
    <RootNamespace>ZeroConfBrowser</RootNamespace>
    <ProjectGuid>711B68E0-44F7-4AE7-AFE7-2E975C3626D8</ProjectGuid>
    <OutputType>Executable</OutputType>
    <AssemblyName>ZeroConfBrowser</AssemblyName>
    <AllowGlobals>False</AllowGlobals>
    <AllowLegacyWith>False</AllowLegacyWith>
    <AllowLegacyOutParams>False</AllowLegacyOutParams>
    <AllowLegacyCreate>False</AllowLegacyCreate>
    <AllowUnsafeCode>False</AllowUnsafeCode>
    <Configuration Condition="'$(Configuration)' == ''">Release</Configuration>
    <SDK>iOS</SDK>
    <CreateAppBundle>True</CreateAppBundle>
    <InfoPListFile>.\Resources\Info.plist</InfoPListFile>
    <DefaultUses />
    <StartupClass />
    <CreateHeaderFile>False</CreateHeaderFile>
    <BundleIdentifier>com.remobjects.develop.rozeroconf</BundleIdentifier>
    <BundleExtension />
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Debug' ">
    <Optimize>false</Optimize>
    <OutputPath>.\bin\Debug</OutputPath>
    <DefineConstants>DEBUG;TRACE;</DefineConstants>
    <GenerateDebugInfo>True</GenerateDebugInfo>
    <EnableAsserts>True</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <ProvisioningProfile>785BF885-D5EA-4F7F-B349-A41D78B9718A</ProvisioningProfile>
    <ProvisioningProfileName>iOS Team Provisioning Profile: * [XKVT6FLBQE.*]</ProvisioningProfileName>
    <CodesignCertificateName>iPhone Developer: marc hoffman (K2YTD84U6W)</CodesignCertificateName>
    <Architecture>armv7;armv7s</Architecture>
  </PropertyGroup>
  <PropertyGroup Condition=" '$(Configuration)' == 'Release' ">
    <Optimize>true</Optimize>
    <OutputPath>.\bin\Release</OutputPath>
    <GenerateDebugInfo>False</GenerateDebugInfo>
    <EnableAsserts>False</EnableAsserts>
    <TreatWarningsAsErrors>False</TreatWarningsAsErrors>
    <CaptureConsoleOutput>False</CaptureConsoleOutput>
    <WarnOnCaseMismatch>True</WarnOnCaseMismatch>
    <CreateIPA>True</CreateIPA>
    <ProvisioningProfile>FBADB74C-AB5C-4B87-A147-EA7214A12DB2</ProvisioningProfile>
    <CodesignCertificateName>iPhone Distribution: RemObjects Software</CodesignCertificateName>
    <ProvisioningProfileName>RemObjects App Store Provision Profile 2014</ProvisioningProfileName>
    <Architecture>armv7;armv7s</Architecture>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="CoreGraphics.fx" />
    <Reference Include="Foundation.fx" />
    <Reference Include="UIKit.fx" />
    <Reference Include="rtl.fx" />
    <Reference Include="libNougat.fx" />
  </ItemGroup>
  <ItemGroup>
    <Compile Include="Program.pas" />
    <Content Include="Resources\Info.plist" />
    <AppResource Include="Resources\App Icons\App-57.png" />
    <AppResource Include="Resources\App Icons\App-72.png" />
    <AppResource Include="Resources\App Icons\App-76.png" />
    <AppResource Include="Resources\App Icons\App-114.png" />
    <AppResource Include="Resources\App Icons\App-120.png" />
    <AppResource Include="Resources\App Icons\App-144.png" />
    <AppResource Include="Resources\App Icons\App-152.png" />
    <None Include="Resources\App Icons\App-512.png" />
    <None Include="Resources\App Icons\App-1024.png" />
    <AppResource Include="Resources\Launch Images\Default.png" />
    <AppResource Include="Resources\Launch Images\Default@2x.png" />
    <AppResource Include="Resources\Launch Images\Default-568h@2x.png" />
    <Compile Include="RootViewController.pas" />
    <Compile Include="AppDelegate.pas" />
    <Compile Include="ServicesViewController.pas" />
    <AppResource Include="Resources\KnownZeroConfTypes.plist" />
    <AppResource Include="Resources\Backgrounds\RegularDetailBackground.png" />
    <AppResource Include="Resources\Backgrounds\RegularDetailBackground@2x.png" />
    <AppResource Include="Resources\Backgrounds\RegularServiceBackground.png" />
    <AppResource Include="Resources\Backgrounds\RegularServiceBackground@2x.png" />
    <AppResource Include="Resources\Backgrounds\RegularServiceBackgroundSelected.png" />
    <AppResource Include="Resources\Backgrounds\RegularServiceBackgroundSelected@2x.png" />
    <AppResource Include="Resources\Services\DataAbstract@2x.png" />
    <AppResource Include="Resources\Services\Elements@2x.png" />
    <AppResource Include="Resources\Services\Relativity@2x.png" />
    <AppResource Include="Resources\Services\RemObjectsSDK@2x.png" />
    <AppResource Include="Resources\Services\Elements.png" />
    <AppResource Include="Resources\Services\DataAbstract.png" />
    <AppResource Include="Resources\Services\Relativity.png" />
    <AppResource Include="Resources\Services\RemObjectsSDK.png" />
  </ItemGroup>
  <ItemGroup>
    <Folder Include="Properties\" />
    <Folder Include="Resources\" />
    <Folder Include="Resources\App Icons\" />
    <Folder Include="Resources\Backgrounds\" />
    <Folder Include="Resources\Launch Images\" />
    <Folder Include="Resources\Services\" />
  </ItemGroup>
  <Import Project="$(MSBuildExtensionsPath)\RemObjects Software\Oxygene\RemObjects.Oxygene.Nougat.targets" />
  <PropertyGroup>
    <PreBuildEvent />
  </PropertyGroup>
</Project>