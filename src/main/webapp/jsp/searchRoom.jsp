<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    .hero-search-wrapper {

        width: 100%;
        display: flex;
        justify-content: center;
         margin: 30px auto;
        z-index: 15;
        overflow: visible;
    }

    .hero-search-wrapper .hotel-search-form {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 80%;
        max-width: 900px;
        margin: 0 auto;
    }

    .hero-search-wrapper .hotel-search-form .search-field {
        flex: 1 1 150px;
        margin: 0 5px;
        display: flex;
        align-items: center;
    }

    .hero-search-wrapper .hotel-search-form .search-submit-btn {
        flex: 0 0 auto;
        margin-left: 5px;
    }

    @media (max-width: 767px) {
        .hero-search-wrapper {
            top: 420px;
        }
    }
</style>

<div class="hero-search-wrapper">
    <form action="${pageContext.request.contextPath}/SearchAvailableRoomsServlet" method="GET" class="hotel-search-form" id="headerSearchForm">
        <!-- Room Type -->
        <div class="search-field roomtype-field">
            <i class="fa fa-bed"></i>
            <select name="roomTypeId" id="roomTypeId">
                <option value="">All Room Types</option>
                <c:forEach var="roomType" items="${searchRoomTypes}">
                    <option value="${roomType.id}" <c:if test="${searchRoomTypeId eq roomType.id}">selected</c:if>>
                        ${roomType.name}
                    </option>
                </c:forEach>
            </select>
        </div>

        <!-- Check-in -->
        <div class="search-field date-field" id="checkinField">
            <div class="date-picker-wrapper">
                <span class="date-label">Check in</span>
                <i class="fa fa-calendar"></i>
                <input type="date" id="checkIn" name="checkIn"
                       value="${searchCheckIn}"
                       title="Select check-in date (today or future)"
                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                       required>
            </div>
        </div>

        <!-- Check-out -->
        <div class="search-field date-field" id="checkoutField">
            <div class="date-picker-wrapper">
                <span class="date-label">Check out</span>
                <i class="fa fa-calendar"></i>
                <input type="date" id="checkOut" name="checkOut"
                       value="${searchCheckOut}"
                       title="Select check-out date (must be after check-in)"
                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 24*60*60*1000)) %>"
                       required>
            </div>
        </div>

        <!-- Occupancy -->
        <div class="search-field occupancy-field">
            <i class="fa fa-user"></i>
            <select name="capacity" id="capacity">
                <option value="1" <c:if test="${searchCapacity eq '1' or empty searchCapacity}">selected</c:if>>1 guest</option>
                <option value="2" <c:if test="${searchCapacity eq '2' }">selected</c:if>>2 guests</option>
                <option value="3" <c:if test="${searchCapacity eq '3'}">selected</c:if>>3 guests</option>
                <option value="4" <c:if test="${searchCapacity eq '4'}">selected</c:if>>4+ guests</option>
            </select>
        </div>

        <!-- Search Button -->
        <button type="submit" class="search-submit-btn">Search</button>
    </form>
</div>