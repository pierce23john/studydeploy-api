FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY ["src/StudyDeployApi/StudyDeployApi.csproj", "src/StudyDeployApi/"]
RUN dotnet restore "src/StudyDeployApi/StudyDeployApi.csproj"

COPY . .
WORKDIR /src/src/StudyDeployApi
RUN dotnet publish "StudyDeployApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "StudyDeployApi.dll"]
