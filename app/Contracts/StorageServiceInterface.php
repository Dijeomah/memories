<?php

namespace App\Contracts;

use Illuminate\Http\UploadedFile;

interface StorageServiceInterface
{
    /**
     * Upload a file
     *
     * @param UploadedFile $file
     * @param string $folder
     * @param array $options
     * @return array ['url' => string, 'public_id' => string, 'format' => string, 'size' => int]
     */
    public function upload(UploadedFile $file, string $folder = '', array $options = []): array;

    /**
     * Delete a file
     *
     * @param string $publicId
     * @return bool
     */
    public function delete(string $publicId): bool;

    /**
     * Get file URL
     *
     * @param string $publicId
     * @param array $transformations
     * @return string
     */
    public function getUrl(string $publicId, array $transformations = []): string;

    /**
     * Generate thumbnail for video
     *
     * @param string $publicId
     * @param array $options
     * @return string
     */
    public function generateVideoThumbnail(string $publicId, array $options = []): string;
}
