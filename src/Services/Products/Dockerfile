FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src


COPY ["SharedSetup/SharedSetup.csproj", "SharedSetup/"]

COPY ["Products/Distribt.Services.Products/Distribt.Services.Orders.csproj", "Orders/Distribt.Services.Orders/"]
COPY ["Orders/Distribt.Services.Orders.BusinessLogic/Distribt.Services.Orders.BusinessLogic.csproj", "Orders/Distribt.Services.Orders.BusinessLogic/"]
COPY ["Orders/Distribt.Services.Orders.Consumer/Distribt.Services.Orders.Consumer.csproj", "Orders/Distribt.Services.Orders.Consumer/"]
COPY ["Orders/Distribt.Services.Orders.Dto/Distribt.Services.Orders.Dto.csproj", "Orders/Distribt.Services.Orders.Dto/"]

