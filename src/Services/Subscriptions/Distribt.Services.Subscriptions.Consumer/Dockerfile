FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src


COPY ["Shared/Distribt.Shared.Setup/Distribt.Shared.Setup.csproj", "Shared/Distribt.Shared.Setup/"]
COPY ["Subscriptions/Distribt.Services.Subscriptions.Consumer/Distribt.Services.Subscriptions.Consumer.csproj", "Subscriptions/Distribt.Services.Subscriptions.Consumer/"]
COPY ["Subscriptions/Distribt.Services.Subscriptions.Dtos/Distribt.Services.Subscriptions.Dtos.csproj", "Subscriptions/Distribt.Services.Subscriptions.Dtos/"]


RUN dotnet restore "Subscriptions/Distribt.Services.Subscriptions.Consumer/Distribt.Services.Subscriptions.Consumer.csproj"

COPY ["Shared/Distribt.Shared.Setup/", "SharedSetup/Distribt.Shared.Setup"]
COPY ["Subscriptions/", "Subscriptions/"]


WORKDIR "/src/Subscriptions/Distribt.Services.Subscriptions.Consumer"
RUN dotnet publish "Distribt.Services.Subscriptions.Consumer.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Distribt.Services.Subscriptions.Consumer.dll"]
