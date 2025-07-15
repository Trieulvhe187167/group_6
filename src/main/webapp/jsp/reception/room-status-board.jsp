<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">


<style>
    .room-card {
        min-height: 250px; /* Hoặc 270 nếu thấy còn ngắn */
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }

</style>

<h2 class="mb-4">Room Status Board</h2>

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
        <option value="AVAILABLE" ${param.status == 'AVAILABLE' ? 'selected' : ''}>Available</option>
        <option value="OCCUPIED" ${param.status == 'OCCUPIED' ? 'selected' : ''}>Occupied</option>
        <option value="MAINTENANCE" ${param.status == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
        <option value="DIRTY" ${param.status == 'DIRTY' ? 'selected' : ''}>Dirty</option>
    </select>
</div>

<!-- Room List Table -->
<div class="table-container">
    <c:choose>
        <c:when test="${not empty rooms}">
            <div class="table-responsive">
                <table class="table table-bordered table-hover table-sm">
                    <thead class="thead-light">
                        <tr>
                            <th>Room</th>
                            <th>Type</th>
                            <th>Capacity</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Guest</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="room" items="${rooms}">
                            <tr class="
                                <c:choose>
                                    <c:when test="${room.status == 'OCCUPIED'}">table-danger</c:when>
                                    <c:when test="${room.status == 'AVAILABLE'}">table-success</c:when>
                                    <c:when test="${room.status == 'DIRTY'}">table-warning</c:when>
                                    <c:when test="${room.status == 'MAINTENANCE'}">table-secondary</c:when>
                                    <c:otherwise>table-light</c:otherwise>
                                </c:choose>
                                ">
                                <td><strong>${room.roomNumber}</strong></td>
                                <td>${room.roomTypeName}</td>
                                <td>${room.capacity}</td>
                                <td>$<fmt:formatNumber value="${room.basePrice}" type="currency" currencySymbol="" maxFractionDigits="2"/></td>
                                <td>
                                    <span class="badge text-dark font-weight-bold
                                          <c:choose>
                                              <c:when test="${room.status == 'AVAILABLE'}">badge-success</c:when>
                                              <c:when test="${room.status == 'OCCUPIED'}">badge-danger</c:when>
                                              <c:when test="${room.status == 'DIRTY'}">badge-warning</c:when>
                                              <c:when test="${room.status == 'MAINTENANCE'}">badge-secondary</c:when>
                                              <c:otherwise>badge-light</c:otherwise>
                                          </c:choose>">
                                        ${room.status}
                                    </span>
                                </td>
                                <td>${room.guestName != null ? room.guestName : '-'}</td>
                                <td><fmt:formatDate value="${room.checkIn}" pattern="yyyy-MM-dd" /></td>
                                <td><fmt:formatDate value="${room.checkOut}" pattern="yyyy-MM-dd" /></td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <c:choose>
                                            <c:when test="${room.status == 'AVAILABLE'}">
                                                <a href="${pageContext.request.contextPath}/receptionist/check-in?roomId=${room.id}" 
                                                   class="btn btn-sm btn-outline-primary" title="Assign to Guest">
                                                    <i class="fas fa-sign-in-alt"></i> Check-In
                                                </a>
                                            </c:when>
                                            <c:when test="${room.status == 'OCCUPIED'}">
                                                <a href="${pageContext.request.contextPath}/receptionist/check-out?roomId=${room.id}" 
                                                   class="btn btn-sm btn-outline-danger" title="Guest Leaving">
                                                    <i class="fas fa-sign-out-alt"></i> Check-Out
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted" data-toggle="tooltip" title="No action from receptionist">N/A</span>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Nút Xem Chi Tiết -->
                                        <button class="btn btn-sm btn-info ml-1"
                                                data-toggle="modal"
                                                data-target="#roomDetailModal"
                                                title="Room Detail"
                                                onclick="showRoomDetail(
                                                                '${room.roomNumber}',
                                                                '${room.roomTypeName}',
                                                                '${room.capacity}',
                                                                '${room.basePrice}',
                                                                '${room.status}',
                                                                '${room.guestName != null ? room.guestName : '-'}',
                                                                '${room.checkIn != null ? room.checkIn : '-'}',
                                                                '${room.checkOut != null ? room.checkOut : '-'}',
                                                                '${room.roomTypeDescription != null ? room.roomTypeDescription : '-'}',
                                                                '${room.imageUrl != null ? room.imageUrl : ''}'
                                                                )">
                                            <i class="fas fa-info-circle"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="alert alert-info">No rooms found for this floor and status filter.</div>
        </c:otherwise>
    </c:choose>
</div>


<!-- Room Detail Modal -->
<div class="modal fade" id="roomDetailModal" tabindex="-1" role="dialog" aria-labelledby="roomDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header bg-info text-white">
                <h5 class="modal-title" id="roomDetailModalLabel">Room Detail</h5>
                <button type="button" class="close text-white" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <!-- Image -->
                    <div class="col-md-5">
                        <img id="roomImage" src="" class="img-fluid rounded border" alt="Room Image">
                    </div>
                    <!-- Info -->
                    <div class="col-md-7">
                        <p><strong>Room:</strong> <span id="modalRoomNumber"></span></p>
                        <p><strong>Type:</strong> <span id="modalRoomType"></span></p>
                        <p><strong>Capacity:</strong> <span id="modalCapacity"></span></p>
                        <p><strong>Price:</strong> $<span id="modalPrice"></span></p>
                        <p><strong>Status:</strong> <span id="modalStatus"></span></p>
                        <p><strong>Guest:</strong> <span id="modalGuest"></span></p>
                        <p><strong>Check-in:</strong> <span id="modalCheckIn"></span></p>
                        <p><strong>Check-out:</strong> <span id="modalCheckOut"></span></p>
                        <p><strong>Description:</strong> <span id="modalDescription"></span></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


<!-- jQuery + Bootstrap -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>

<script>
                                                    document.addEventListener("DOMContentLoaded", function () {
                                                        // Gán lại giá trị cho dropdown Status nếu có từ server
                                                        const currentStatus = "${param.status != null ? param.status : ''}";
                                                        const statusFilter = document.getElementById("statusFilter");

                                                        if (statusFilter && currentStatus) {
                                                            statusFilter.value = currentStatus;
                                                        }

                                                        // Kích hoạt tooltip nếu đang dùng Bootstrap (jQuery)
                                                        if (typeof $ !== 'undefined' && typeof $.fn.tooltip !== 'undefined') {
                                                            $('[data-toggle="tooltip"]').tooltip();
                                                        }
                                                    });

                                                    function filterStatus() {
                                                        const statusElement = document.getElementById("statusFilter");
                                                        if (!statusElement)
                                                            return;

                                                        const selectedStatus = statusElement.value;

                                                        // Tạo URL mới dựa trên URL hiện tại
                                                        const url = new URL(window.location.href);

                                                        // Set status mới
                                                        url.searchParams.set("status", selectedStatus);

                                                        // Giữ lại hoặc gán floor nếu chưa có
                                                        const floor = url.searchParams.get("floor");
                                                        if (!floor || floor === '') {
                                                            url.searchParams.set("floor", "${selectedFloor != null ? selectedFloor : '1'}");
                                                        }

                                                        // Chuyển hướng
                                                        window.location.href = url.toString();
                                                    }
</script>

<script>
    function showRoomDetail(roomNumber, type, capacity, price, status, guest, checkIn, checkOut, description, imageUrl) {
        document.getElementById("modalRoomNumber").textContent = roomNumber;
        document.getElementById("modalRoomType").textContent = type;
        document.getElementById("modalCapacity").textContent = capacity;
        document.getElementById("modalPrice").textContent = price;
        document.getElementById("modalStatus").textContent = status;
        document.getElementById("modalGuest").textContent = guest;
        document.getElementById("modalCheckIn").textContent = checkIn;
        document.getElementById("modalCheckOut").textContent = checkOut;
        document.getElementById("modalDescription").textContent = description;

        const img = document.getElementById("roomImage");
        if (imageUrl && imageUrl !== "null") {
            img.src = imageUrl;
        } else {
            img.src = "https://via.placeholder.com/400x300?text=No+Image";
        }
    }
</script>




