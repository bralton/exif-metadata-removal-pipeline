"""
Lambda function to remove EXIF metadata from JPG images.

This function is triggered by EventBridge when a new JPG file is uploaded to S3 Bucket A.
It downloads the image, removes all EXIF metadata, and uploads the sanitized image to S3 Bucket B on the same filepath as Bucket A.
"""

import json
import os
import logging
from io import BytesIO
from typing import Dict, Any

import boto3
from PIL import Image
from botocore.exceptions import ClientError

# Configure logging
LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)

# Initialize S3 client
s3_client = boto3.client('s3')

# Get destination bucket from environment variable
DESTINATION_BUCKET = os.environ.get('DESTINATION_BUCKET')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler function.

    Args:
        event: EventBridge event containing S3 object information
        context: Lambda context object

    Returns:
        Dict with status code and response message
    """
    # Validate destination bucket is configured
    if not DESTINATION_BUCKET:
        error_msg = "DESTINATION_BUCKET environment variable not set"
        logger.error(error_msg)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_msg})
        }

    try:
        # Extract S3 bucket and key from EventBridge event
        detail = event.get('detail', {})
        bucket_name = detail.get('bucket', {}).get('name')
        object_key = detail.get('object', {}).get('key')

        if not bucket_name or not object_key:
            error_msg = "Missing bucket name or object key in event"
            logger.error(error_msg)
            return {
                'statusCode': 400,
                'body': json.dumps({'error': error_msg})
            }

        logger.info(f"Processing file: s3://{bucket_name}/{object_key}")

        # Download the image from S3
        image_data = download_image_from_s3(bucket_name, object_key)

        # Remove EXIF metadata
        sanitized_image_data = remove_exif_metadata(image_data)

        # Upload sanitized image to destination bucket
        upload_image_to_s3(DESTINATION_BUCKET, object_key, sanitized_image_data)

        success_msg = f"Finished processing {object_key} successfully."
        logger.info(success_msg)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': success_msg,
                'source': f's3://{bucket_name}/{object_key}',
                'destination': f's3://{DESTINATION_BUCKET}/{object_key}'
            })
        }

    except ClientError as e:
        error_msg = f"AWS error: {str(e)}"
        logger.error(error_msg, exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_msg})
        }

    except Exception as e:
        error_msg = f"Unexpected error: {str(e)}"
        logger.error(error_msg, exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_msg})
        }


def download_image_from_s3(bucket: str, key: str) -> bytes:
    """
    Download an image from S3.

    Args:
        bucket: S3 bucket name
        key: S3 object key

    Returns:
        Image data as bytes

    Raises:
        ClientError: If S3 download fails
    """
    logger.info(f"Downloading s3://{bucket}/{key}")

    response = s3_client.get_object(Bucket=bucket, Key=key)
    image_data = response['Body'].read()

    logger.info(f"Downloaded {len(image_data)} bytes")
    return image_data


def remove_exif_metadata(image_data: bytes) -> bytes:
    """
    Remove EXIF metadata from a JPG image.

    Args:
        image_data: Original image data as bytes

    Returns:
        Sanitized image data as bytes without EXIF metadata

    Raises:
        Exception: If image processing fails

    Claude Code helped with this function.
    """
    logger.info("Removing EXIF metadata")

    # Open the image
    image = Image.open(BytesIO(image_data))

    # Log original image info
    logger.info(f"Original image: format={image.format}, size={image.size}, mode={image.mode}")

    # Check if image has EXIF data
    exif_data = image.getexif()
    if exif_data:
        logger.info(f"Found {len(exif_data)} EXIF tags")
    else:
        logger.info("No EXIF data found")

    # Create a new image without EXIF data
    # Converting to RGB if necessary (some images may be in different modes)
    if image.mode not in ('RGB', 'L'):
        logger.info(f"Converting image from {image.mode} to RGB")
        image = image.convert('RGB')

    # Save the image without EXIF data
    output = BytesIO()
    image.save(output, format='JPEG', quality=95, optimize=True)
    sanitized_data = output.getvalue()

    logger.info(f"Sanitized image size: {len(sanitized_data)} bytes")
    logger.info(f"Size reduction: {len(image_data) - len(sanitized_data)} bytes")

    return sanitized_data


def upload_image_to_s3(bucket: str, key: str, image_data: bytes) -> None:
    """
    Upload an image to S3.

    Args:
        bucket: S3 bucket name
        key: S3 object key (preserves original path)
        image_data: Image data as bytes

    Raises:
        ClientError: If S3 upload fails
    """
    logger.info(f"Uploading to s3://{bucket}/{key}")

    s3_client.put_object(
        Bucket=bucket,
        Key=key,
        Body=image_data,
        ContentType='image/jpeg',
    )

    logger.info(f"Successfully uploaded s3://{bucket}/{key}")
