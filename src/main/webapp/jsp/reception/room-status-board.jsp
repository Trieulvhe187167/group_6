<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<h4 class="mb-4">Room Status Board</h4>

<!-- Floor selection -->
<div class="mb-3">
    <label class="mr-2 font-weight-bold">Select Floor:</label>
    <c:forEach var="floor" items="${floors}">
        <a href="?floor=${floor}&status=${param.status}" 
           class="btn btn-outline-info mb-2 ${floor == selectedFloor ? 'active' : ''}">
            Floor ${floor}
        </a>
    </c:forEach>
</div>

<!-- Status Filter -->
<div class="mb-3">
    <label for="statusFilter">Filter by Status:</label>
    <select id="statusFilter" class="form-control w-auto d-inline-block" onchange="filterStatus()">
        <option value="">All</option>
        <option value="AVAILABLE">Available</option>
        <option value="OCCUPIED">Occupied</option>
        <option value="MAINTENANCE">Maintenance</option>
        <option value="DIRTY">Dirty</option>
    </select>
</div>

<!-- Room Cards -->
<div class="row">
    <c:forEach var="room" items="${rooms}">
        <div class="col-md-3 mb-4">
            <div class="card text-white
                 <c:choose>
                     <c:when test="${room.status == 'OCCUPIED'}">bg-danger</c:when>
                     <c:when test="${room.status == 'AVAILABLE'}">bg-success</c:when>
                     <c:when test="${room.status == 'DIRTY'}">bg-warning</c:when>
                     <c:when test="${room.status == 'MAINTENANCE'}">bg-secondary</c:when>
                     <c:otherwise>bg-dark</c:otherwise>
                 </c:choose>">
                <div class="card-body text-center">
                    <h5>Room ${room.roomNumber}</h5>
                    <p>${room.roomTypeName}</p>
                    <small>${room.capacity} guests - $${room.basePrice}</small><br>
                    <strong>${room.status}</strong>

                    <c:if test="${room.status == 'OCCUPIED' || room.status == 'RESERVED'}">
                        <hr>
                        <div>
                            <small>Guest: ${room.guestName}</small><br>
                            <small>Check-in: ${room.checkIn}</small><br>
                            <small>Check-out: ${room.checkOut}</small>
                            <pre>${room}</pre>

                        </div>
                    </c:if>

                    <c:if test="${room.status == 'AVAILABLE'}">
                        <a href="${pageContext.request.contextPath}/receptionist/check-in?roomId=${room.id}" class="btn btn-light btn-sm mt-2">
                            <i class="fas fa-sign-in-alt"></i> Check-In
                        </a>
                    </c:if>

                    <c:if test="${room.status == 'OCCUPIED'}">
                        <a href="${pageContext.request.contextPath}/receptionist/check-out?roomId=${room.id}" class="btn btn-light btn-sm mt-2">
                            <i class="fas fa-sign-out-alt"></i> Check-Out
                        </a>
                    </c:if>
                </div>
            </div>
        </div>
    </c:forEach>
</div>

<script>
    function filterStatus() {
        const status = document.getElementById("statusFilter").value;
        const url = new URL(window.location.href);
        url.searchParams.set('status', status);
        window.location.href = url.toString();
    }

    // Keep selected value on reload
    document.addEventListener("DOMContentLoaded", () => {
        document.getElementById("statusFilter").value = "${status}";
    });
</script>
<script>
    function filterStatus() {
        const status = document.getElementById("statusFilter").value;

        // Lấy URL hiện tại
        const url = new URL(window.location.href);

        // Cập nhật hoặc thêm status mới
        url.searchParams.set("status", status);

        // Giữ lại floor đang chọn (nếu có)
        const floor = url.searchParams.get("floor");
        if (!floor) {
            url.searchParams.set("floor", ${selectedFloor});
        }

        // Reload với query mới
        window.location.href = url.toString();
    }

    // Sau khi load xong thì gán lại giá trị status đã chọn
    document.addEventListener("DOMContentLoaded", () => {
        document.getElementById("statusFilter").value = "${status}";
    });
</script>

<script>
    $(function () {
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>

