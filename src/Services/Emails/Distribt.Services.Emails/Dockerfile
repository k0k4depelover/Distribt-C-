FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY ["src/Services/Emails/Distribt.Services.Emails/Distribt.Services.Emails.csproj" , "Services/Emails"]
COPY ["src/Shared/Distribt.Shared.Setup/Distribt.Shared.Setup.csproj", "Shared/Distribt.Shared.Setup/"] 


RUN dotnet restore "Services/Emails/Distribt.Services.Emails/Distribt.Services.Emails.csproj"

COPY ["src/Services/Emails/Distribt.Services.Emails/", "Services/Emails/Distribt.Services.Emails/"]
COPY ["src/Shared/Distribt.Shared.Setup/", "Shared/Distribt.Shared.Setup/"]

WORKDIR "/src/Services/Emails/Distribt.Services.Emails"
RUN dotnet build "Distribt.Services.Emails.csproj" -c Release -o /app/build
RUN dotnet publish "Distribt.Services.Emails.csproj" -c Release -o /app/publish

FROM mrc.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http//+:8000
EXPOSE 8080