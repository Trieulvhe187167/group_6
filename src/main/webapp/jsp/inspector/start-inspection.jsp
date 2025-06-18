<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container-fluid">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/inspector/dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Start Inspection</li>
        </ol>
    </nav>
    
    <h1 class="mb-4">Start Room Inspection</h1>
    
    <!-- Reservation Details -->
    <div class="card mb-4">
        <div class="card-header bg-info text-white">
            <h5 class="mb-0">Reservation Details</h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-3">
                    <strong>Booking ID:</strong><br>
                    #${reservation.id}
                </div>
                <div class="col-md-3">
                    <strong>Room:</strong><br>
                    ${reservation.room.roomNumber} - ${reservation.room.roomTypeName}
                </div>
                <div class="col-md-3">
                    <strong>Guest:</strong><br>
                    ${reservation.customerName}<br>
                    <small>${reservation.customerPhone}</small>
                </div>
                <div class="col-md-3">
                    <strong>Stay Period:</strong><br>
                    <fmt:formatDate value="${reservation.checkIn}" pattern="dd/MM/yyyy"/> - 
                    <fmt:formatDate value="${reservation.checkOut}" pattern="dd/MM/yyyy"/>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Inspection Form -->
    <form method="post" action="${pageContext.request.contextPath}/inspector/inspection" 
          class="inspection-form">
        <input type="hidden" name="action" value="create">
        <input type="hidden" name="reservationId" value="${reservation.id}">
        
        <h4 class="mb-3">Initial Assessment</h4>
        
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="roomCondition">Room Condition <span class="text-danger">*</span></label>
                    <select class="form-control" id="roomCondition" name="roomCondition" required>
                        <option value="">Select condition...</option>
                        <option value="EXCELLENT">Excellent - No issues found</option>
                        <option value="GOOD">Good - Minor cleaning needed</option>
                        <option value="FAIR">Fair - Some issues found</option>
                        <option value="POOR">Poor - Multiple issues</option>
                        <option value="DAMAGED">Damaged - Significant damage</option>
                    </select>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label>Cleanliness Score <span class="text-danger">*</span></label>
                    <div class="cleanliness-rating">
                        <c:forEach begin="1" end="10" var="i">
                            <input type="radio" id="score${i}" name="cleanlinessScore" value="${i}" required>
                            <label for="score${i}">
                                <i class="fas fa-star"></i>
                            </label>
                        </c:forEach>
                        <span class="ml-3" id="scoreText">Select a rating</span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="form-group">
            <label for="notes">Initial Notes</label>
            <textarea class="form-control" id="notes" name="notes" rows="4" 
                      placeholder="Enter any initial observations..."></textarea>
        </div>
        
        <!-- Available Amenities Checklist -->
        <h4 class="mb-3 mt-4">Room Amenities Checklist</h4>
        <div class="alert alert-info">
            <i class="fas fa-info-circle"></i> 
            Below are the chargeable amenities for this room. You'll be able to record usage in the next step.
        </div>
        
        <div class="row">
            <c:forEach var="amenity" items="${amenities}">
                <div class="col-md-6 mb-2">
                    <div class="custom-control custom-checkbox">
                        <input type="checkbox" class="custom-control-input" 
                               id="amenity${amenity.id}" checked disabled>
                        <label class="custom-control-label" for="amenity${amenity.id}">
                            ${amenity.name}
                            <c:if test="${amenity.unitPrice > 0}">
                                - <fmt:formatNumber value="${amenity.unitPrice}" pattern="#,##0"/>₫
                            </c:if>
                        </label>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <hr class="my-4">
        
        <div class="text-center">
            <button type="submit" class="btn btn-primary btn-lg">
                <i class="fas fa-play"></i> Start Detailed Inspection
            </button>
            <a href="${pageContext.request.contextPath}/inspector/dashboard" 
               class="btn btn-secondary btn-lg ml-2">
                <i class="fas fa-times"></i> Cancel
            </a>
        </div>
    </form>
</div>

<script>
// Cleanliness rating interaction
$(document).ready(function() {
    const scoreTexts = [
        '', 'Very Poor', 'Poor', 'Below Average', 'Fair', 
        'Average', 'Above Average', 'Good', 'Very Good', 'Excellent', 'Perfect'
    ];
    
    $('input[name="cleanlinessScore"]').on('change', function() {
        const score = parseInt($(this).val());
        $('#scoreText').text(scoreTexts[score] + ' (' + score + '/10)');
        
        // Update star colors
        $('input[name="cleanlinessScore"]').each(function(index) {
            if (index < score) {
                $(this).next('label').find('i').removeClass('far').addClass('fas');
            } else {
                $(this).next('label').find('i').removeClass('fas').addClass('far');
            }
        });
    });
    
    // Hover effect for stars
    $('.cleanliness-rating label').hover(
        function() {
            const index = $(this).prev('input').val();
            $('.cleanliness-rating label').each(function() {
                if ($(this).prev('input').val() <= index) {
                    $(this).find('i').addClass('text-warning');
                }
            });
        },
        function() {
            $('.cleanliness-rating label i').removeClass('text-warning');
        }
    );
});
</script>