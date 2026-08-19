FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src


COPY ["Shared/Distribt.Shared.Setup/", "SharedSetup/Distribt.Shared.Setup/"]

COPY ["Products/Distribt.Services.Products.Consumer/Distribt.Services.Products.Consumer.csproj", "Products/Distribt.Services.Products.Consumer/"]
COPY ["Products/Distribt.Services.Products.BusinessLogic/Distribt.Services.Products.BusinessLogic.csproj", "Products/Distribt.Services.Products.BusinessLogic/"]


RUN dotnet restore "Products/Distribt.Services.Products.Consumer/Distribt.Services.Products.Consumer.csproj"

COPY ["Shared/Distribt.Shared.Setup/", "SharedSetup/Distribt.Shared.Setup"]
COPY ["Products/", "Products/"]


WORKDIR "/src/Products/Distribt.Services.Products.Consumer"
RUN dotnet publish "Distribt.Services.Products.Consumer.csproj" -c Release -o /app/publish /p:UseAppHost=false


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Distribt.Services.Products.Consumer.dll"]
