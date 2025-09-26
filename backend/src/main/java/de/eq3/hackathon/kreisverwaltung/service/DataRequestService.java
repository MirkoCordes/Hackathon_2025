package de.eq3.hackathon.kreisverwaltung.service;

import de.eq3.hackathon.kreisverwaltung.entity.DataRequest;
import de.eq3.hackathon.kreisverwaltung.entity.DataRequestResponse;
import de.eq3.hackathon.kreisverwaltung.entity.Datasource;
import de.eq3.hackathon.kreisverwaltung.entity.User;
import de.eq3.hackathon.kreisverwaltung.repository.DataRequestRepository;
import de.eq3.hackathon.kreisverwaltung.repository.DataRequestResponseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DataRequestService {

    private final DataRequestRepository dataRequestRepository;
    private final DataRequestResponseRepository responseRepository;

    // === MARKETPLACE STATISTICS ===

    public Map<String, Object> getMarketplaceStatistics() {
        Map<String, Object> stats = new HashMap<>();

        // Basic counts
        stats.put("totalRequests", dataRequestRepository.count());
        stats.put("openRequests", dataRequestRepository.findByStatus(DataRequest.Status.OPEN).size());
        stats.put("fulfilledRequests", dataRequestRepository.findByStatus(DataRequest.Status.FULFILLED).size());
        stats.put("totalResponses", responseRepository.count());

        // Recent activity
        LocalDateTime lastWeek = LocalDateTime.now().minusDays(7);
        stats.put("newRequestsThisWeek", dataRequestRepository.findRecentRequests(lastWeek).size());

        // Category breakdown
        Map<String, Long> categoryStats = new HashMap<>();
        for (Datasource.Category category : Datasource.Category.values()) {
            Long count = dataRequestRepository.countOpenRequestsByCategory(category);
            categoryStats.put(category.name(), count);
        }
        stats.put("requestsByCategory", categoryStats);

        // Priority breakdown
        Map<String, Integer> priorityStats = new HashMap<>();
        for (DataRequest.Priority priority : DataRequest.Priority.values()) {
            int count = dataRequestRepository.findByPriorityOrderByCreatedAtDesc(priority).size();
            priorityStats.put(priority.name(), count);
        }
        stats.put("requestsByPriority", priorityStats);

        return stats;
    }

    // === SEARCH & FILTERING ===

    public List<DataRequest> searchRequests(String keyword, Datasource.Category category, DataRequest.Status status) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            return dataRequestRepository.searchByKeywordAndStatus(keyword.trim(), status);
        } else if (category != null) {
            return dataRequestRepository.findByCategoryOrderByCreatedAtDesc(category);
        } else {
            return dataRequestRepository.findByStatusOrderByCreatedAtDesc(status);
        }
    }

    public List<DataRequest> getPopularRequests() {
        return dataRequestRepository.findPopularOpenRequests();
    }

    public List<DataRequest> getUnansweredRequests() {
        return dataRequestRepository.findOpenRequestsWithoutResponses();
    }

    // === USER ANALYTICS ===

    public Map<String, Object> getUserStatistics(User user) {
        Map<String, Object> stats = new HashMap<>();

        stats.put("totalRequests", dataRequestRepository.countByUser(user));
        stats.put("totalResponses", responseRepository.countByResponder(user));

        List<DataRequest> userRequests = dataRequestRepository.findByUserOrderByCreatedAtDesc(user);
        long openRequests = userRequests.stream().filter(DataRequest::isOpen).count();
        stats.put("openRequests", openRequests);

        // Response rate on user's requests
        long totalResponsesReceived = userRequests.stream()
                .mapToLong(request -> responseRepository.countByDataRequest(request))
                .sum();
        stats.put("totalResponsesReceived", totalResponsesReceived);

        return stats;
    }

    // === RECOMMENDATION ENGINE (BASIC) ===

    public List<DataRequest> getRecommendedRequestsForUser(User user) {
        // Simple recommendation based on user's previous activity
        List<DataRequest> userRequests = dataRequestRepository.findByUserOrderByCreatedAtDesc(user);

        if (userRequests.isEmpty()) {
            // New user - show popular requests
            return dataRequestRepository.findPopularOpenRequests().stream().limit(5).toList();
        }

        // Find most common category from user's requests
        Map<Datasource.Category, Long> categoryCount = new HashMap<>();
        for (DataRequest request : userRequests) {
            categoryCount.merge(request.getCategory(), 1L, Long::sum);
        }

        Optional<Datasource.Category> mostCommonCategory = categoryCount.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey);

        if (mostCommonCategory.isPresent()) {
            return dataRequestRepository.findByCategoryOrderByCreatedAtDesc(mostCommonCategory.get())
                    .stream()
                    .filter(DataRequest::isOpen)
                    .filter(request -> !request.isOwnedBy(user))
                    .limit(5)
                    .toList();
        }

        return dataRequestRepository.findByStatusOrderByCreatedAtDesc(DataRequest.Status.OPEN)
                .stream()
                .filter(request -> !request.isOwnedBy(user))
                .limit(5)
                .toList();
    }

    // === MATCHING ALGORITHMS ===

    public List<DataRequest> findMatchingRequests(Datasource datasource) {
        // Find requests that might match this datasource
        return dataRequestRepository.findByCategoryOrderByCreatedAtDesc(datasource.getCategory())
                .stream()
                .filter(DataRequest::isOpen)
                .limit(10)
                .toList();
    }

    // === NOTIFICATION HELPERS ===

    public boolean shouldNotifyRequestOwner(DataRequest request) {
        // Notify if new response and no notification sent in last 24h
        return request.isOpen() &&
                request.hasResponses() &&
                request.getLastUpdated().isBefore(LocalDateTime.now().minusHours(24));
    }

    public List<DataRequest> getRequestsNeedingAttention() {
        // Requests that are older than 30 days without responses
        return dataRequestRepository.findOpenRequestsWithoutResponses()
                .stream()
                .filter(request -> request.getCreatedAt().isBefore(LocalDateTime.now().minusDays(30)))
                .toList();
    }

    // === VALIDATION HELPERS ===

    public boolean canUserRespondToRequest(User user, DataRequest request) {
        if (request.isOwnedBy(user)) {
            return false; // Can't respond to own request
        }

        if (!request.isOpen()) {
            return false; // Request is closed
        }

        return !responseRepository.existsByDataRequestAndResponder(request, user);
    }

    public boolean canUserEditRequest(User user, DataRequest request) {
        return request.isOwnedBy(user) || user.getRole() == User.Role.ADMIN;
    }

    public boolean canUserManageResponse(User user, DataRequestResponse response) {
        return response.getDataRequest().isOwnedBy(user) ||
                response.isOwnedBy(user) ||
                user.getRole() == User.Role.ADMIN;
    }
}