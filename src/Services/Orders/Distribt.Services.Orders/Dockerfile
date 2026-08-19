FROM mrc.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY ["src/Services/Orders/Distribt.Services.Orders/Distribt.Services.Orders.csproj", "Orders/Distribt.Services.Orders/"]
COPY ["src/Services/Orders/Distribt.Services.Orders.BusinessLogic/Distribt.Services.Orders.BusinessLogic.csproj", "Orders/Distribt.Services.Orders.BusinessLogic/"]
COPY ["src/Services/Orders/Distribt.Services.Orders.Consumer/Distribt.Services.Orders.Consumer.csproj", "Orders/Distribt.Services.Orders.Consumer/"]
COPY ["src/Services/Orders/Distribt.Services.Orders.Dto/Distribt.Services.Orders.Dto.csproj", "Orders/Distribt.Services.Orders.Dto/"]

RUN dotnet restore "src/Services/Orders/Distribt.Services.Orders/Distribt.Services.Orders.csproj"

COPY . .

WORKDIR "/src/Services/Orders/Distribt.Services.Orders"

RUN dotnet publish "Distribt.Services.Orders.csproj" -c Release -o /app/publish /p:UseAppHost=false



FROM mrc.microsoft.com/dotnet/aspnet:8.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8000
EXPOSE 8080


ENTRYPOINT [ "Distribt.Services.Orders.dll" ]

