<?php
// Script to map CodeIgniter database rows to camelCase for React
$content = file_get_contents('backend/app/Controllers/PublicController.php');
$newCode = "
    private function attachServiceMixAndFeatures(&\$pkg) {
        // CamelCase Mapping
        \$pkg['totalLinks'] = \$pkg['total_links'] ?? 0;
        \$pkg['durationDays'] = \$pkg['duration_days'] ?? 0;
        \$pkg['deliveryPhases'] = \$pkg['delivery_phases'] ?? 0;
        \$pkg['priceUsd'] = \$pkg['price_usd'] ?? 0;
        \$pkg['isActive'] = \$pkg['is_active'] ?? 0;
        \$pkg['isFeatured'] = \$pkg['is_featured'] ?? 0;

        if (\$pkg['slug'] === 'starter-authority') {
            \$pkg['description'] = 'A balanced baseline backlink portfolio designed to establish trust metrics with search engines without triggering algorithmic velocity filters.';
            \$pkg['serviceMix'] = [
                'contentPublishing' => 2, 'haBacklinks' => 3, 'haTierText' => 'DR 30-50',
                'profileBacklinks' => 30, 'profileTierText' => 'DA 40+', 'web2Backlinks' => 15
            ];
            \$pkg['features'] = [
                '2 Content Publishing placements', '3 High Authority Backlinks (DR 30-50)',
                '30 High DA Authority Links (DA 40+)', '15 High Quality Website Links',
                'Natural anchor text ratio optimization', 'Spread across 4 distinct delivery phases',
                'Phase-by-phase Google Sheet live reports', 'No guest posts — 100% written & published'
            ];
        } else if (\$pkg['slug'] === 'growth-authority') {
            \$pkg['description'] = 'Strategic link blend combining editorial content publishing, curated niche edits on aged articles, and high domain rating backlinks to push page-one rankings.';
            \$pkg['serviceMix'] = [
                'contentPublishing' => 5, 'haBacklinks' => 8, 'haTierText' => 'DR 40-60',
                'nicheEdits' => 5, 'profileBacklinks' => 50, 'profileTierText' => 'DA 40+', 'web2Backlinks' => 25
            ];
            \$pkg['features'] = [
                '5 Content Publishing placements', '8 High Authority Backlinks (DR 40-60)',
                '5 Niche Edit Backlinks', '50 High DA Authority Links (DA 40+)',
                '25 High Quality Website Links', '6 Weekly delivery phases over 45 days',
                'Dedicated Google Sheet per phase', 'Drip-feed indexing strategy & report tracking'
            ];
        } else if (\$pkg['slug'] === 'professional-authority') {
            \$pkg['description'] = 'Accelerated authority acquisition featuring DR 50-70 authority links, 10 niche insertions, and 10 bespoke articles crafted by native industry specialists.';
            \$pkg['serviceMix'] = [
                'contentPublishing' => 10, 'haBacklinks' => 20, 'haTierText' => 'DR 50-70',
                'nicheEdits' => 10, 'profileBacklinks' => 75, 'profileTierText' => 'DA 50+', 'web2Backlinks' => 40
            ];
            \$pkg['features'] = [
                '10 Content Publishing placements', '20 High Authority Backlinks (DR 50-70)',
                '10 Niche Edit Backlinks', '75 High DA Authority Links (DA 50+)',
                '40 High Quality Website Links', '8 Delivery phases over 60 days',
                'Live Google Sheet updates with DR/DA verification', 'Dedicated account manager review'
            ];
        } else if (\$pkg['slug'] === 'business-authority') {
            \$pkg['description'] = 'Designed for enterprise brands, national lead generation, and competitive e-commerce requiring national press exposure paired with DR 60-80 contextual backlinks.';
            \$pkg['serviceMix'] = [
                'contentPublishing' => 20, 'haBacklinks' => 35, 'haTierText' => 'DR 60-80',
                'nicheEdits' => 20, 'profileBacklinks' => 100, 'profileTierText' => 'DA 50+', 'web2Backlinks' => 50, 'pressRelease' => 5
            ];
            \$pkg['features'] = [
                '20 Content Publishing placements', '35 High Authority Backlinks (DR 60-80)',
                '20 Niche Edit Backlinks', '100 High DA Authority Links (DA 50+)',
                '50 High Quality Website Links', '5 Press Release Distribution',
                '12 Scheduled delivery phases (90 days)', 'Live Google Sheet with real-time indexing status'
            ];
        } else if (\$pkg['slug'] === 'enterprise-authority') {
            \$pkg['description'] = 'Maximum velocity authority infrastructure combining Digital PR media mentions, 15 national wire releases, 40 published articles, and 60 top-tier DR 70+ links.';
            \$pkg['serviceMix'] = [
                'contentPublishing' => 40, 'haBacklinks' => 60, 'haTierText' => 'DR 70+',
                'nicheEdits' => 40, 'profileBacklinks' => 200, 'profileTierText' => 'DA 60+', 'web2Backlinks' => 100,
                'pressRelease' => 15, 'digitalPr' => 10
            ];
            \$pkg['features'] = [
                '40 Content Publishing placements', '60 High Authority Backlinks (DR 70+)',
                '40 Niche Edit Backlinks', '200 High DA Authority Links (DA 60+)',
                '100 High Quality Website Links', '15 Press Release Distribution',
                '10 Digital PR Mentions', '16 Scheduled phases with milestone delivery checkpoints',
                'Google Sheets master dashboard with live link monitoring'
            ];
        } else {
            \$pkg['description'] = '';
            \$pkg['serviceMix'] = [
                'contentPublishing' => 0, 'haBacklinks' => 0, 'haTierText' => '',
                'profileBacklinks' => 0, 'profileTierText' => '', 'web2Backlinks' => 0
            ];
            \$pkg['features'] = [];
        }
    }
";
// Replace the old attachServiceMixAndFeatures block with the new one
$content = preg_replace('/private function attachServiceMixAndFeatures\(.*?\}\s*\}/s', trim($newCode), $content);
file_put_contents('backend/app/Controllers/PublicController.php', $content);
