<?php

namespace App\Services\Storage;

use App\Contracts\StorageServiceInterface;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class DigitalOceanStorageService implements StorageServiceInterface
{
    protected string $disk = 'spaces';

    /**
     * Upload a file to DigitalOcean Spaces
     *
     * @param UploadedFile $file
     * @param string $folder
     * @param array $options
     * @return array
     */
    public function upload(UploadedFile $file, string $folder = '', array $options = []): array
    {
        $filename = $this->generateFilename($file);
        $path = $folder ? "{$folder}/{$filename}" : $filename;

        $visibility = $options['visibility'] ?? 'public';

        $uploaded = Storage::disk($this->disk)->putFileAs(
            $folder,
            $file,
            $filename,
            $visibility
        );

        $url = Storage::disk($this->disk)->url($uploaded);

        return [
            'url' => $url,
            'public_id' => $uploaded,
            'format' => $file->getClientOriginalExtension(),
            'size' => $file->getSize(),
            'width' => null,
            'height' => null,
            'resource_type' => $this->getResourceType($file),
        ];
    }

    /**
     * Delete a file from DigitalOcean Spaces
     *
     * @param string $publicId
     * @return bool
     */
    public function delete(string $publicId): bool
    {
        try {
            return Storage::disk($this->disk)->delete($publicId);
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Get file URL from DigitalOcean Spaces
     *
     * @param string $publicId
     * @param array $transformations
     * @return string
     */
    public function getUrl(string $publicId, array $transformations = []): string
    {
        // Note: DigitalOcean Spaces doesn't support transformations like Cloudinary
        // You would need to implement a separate image processing service if needed
        return Storage::disk($this->disk)->url($publicId);
    }

    /**
     * Generate thumbnail for video
     *
     * @param string $publicId
     * @param array $options
     * @return string
     */
    public function generateVideoThumbnail(string $publicId, array $options = []): string
    {
        // Note: This would require a separate video processing service
        // For now, return a placeholder or the original URL
        return Storage::disk($this->disk)->url($publicId);
    }

    /**
     * Generate unique filename
     *
     * @param UploadedFile $file
     * @return string
     */
    protected function generateFilename(UploadedFile $file): string
    {
        $extension = $file->getClientOriginalExtension();
        $filename = Str::random(40);
        return "{$filename}.{$extension}";
    }

    /**
     * Determine resource type based on file mime type
     *
     * @param UploadedFile $file
     * @return string
     */
    protected function getResourceType(UploadedFile $file): string
    {
        $mimeType = $file->getMimeType();

        if (str_starts_with($mimeType, 'video/')) {
            return 'video';
        }

        if (str_starts_with($mimeType, 'image/')) {
            return 'image';
        }

        return 'auto';
    }
}
