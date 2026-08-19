FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src


COPY ["Shared/Distribt.Shared.Setup/", "SharedSetup/Distribt.Shared.Setup/"]

COPY ["Subscriptions/Distribt.Services.Subscriptions/Distribt.Services.Subscriptions.csproj", "Subscriptions/Distribt.Services.Subscriptions/"]
COPY ["Subscriptions/Distribt.Services.Subscriptions.Dtos/Distribt.Services.Subscriptions.Dtos.csproj", "Subscriptions/Distribt.Services.Subscriptions.Dtos/"]


RUN dotnet restore "Subscriptions/Distribt.Services.Subscriptions/Distribt.Services.Subscriptions.csproj"

COPY ["Shared/Distribt.Shared.Setup/", "SharedSetup/Distribt.Shared.Setup"]
COPY ["Subscriptions/", "Subscriptions/"]


WORKDIR "/src/Subscriptions/Distribt.Services.Subscriptions"
RUN dotnet publish "Distribt.Services.Subscriptions.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Distribt.Services.Subscriptions.dll"]
